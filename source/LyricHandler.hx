package source;

import sys.io.File;
import haxe.Exception;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxBasic;
import funkin.backend.assets.ModsFolder;
import source.Signal;

/**
	The object used to handle lyrics.
**/
class LyricHandler extends FlxBasic {
	/**
	 * The `SequencedLine`s for this `LyricHandler`.
	 */
	public var sequence:Array<SequencedLine> = [];

	/**
	 * `SequencedLine`s that are have not been played yet.
	 */
	public var unplayedLines:Array<SequencedLine> = [];

	/**
	 * `SequencedLine`s that have already been played.
	 */
	public var elapsedLines:Array<SequencedLine> = [];

	/**
	 * Dynamic that fires if the next line is played.
	 */
	public var onLyricShow:Dynamic<SequencedLine->Void>;

	/**
	 * Number of lines played so far.
	 */
	public var linesPlayed:Int = 0;

	/**
	 * Map that shows ID tags. Useful for metadata.
	 */
	public var extras:Map<String, String> = [];

	/**
	 * Determines how much to offset the lyrics for synchronization in milliseconds
	 *
	 * To apply it, add `[offset:n]` in your lyric file, or alternatively, set this variable directly.
	 */
	public var offset:Float = 0;

	public function new() {
		super();
		onLyricShow = new Signal();
	}

	/**
	 * Parses a string and turns it into `SequencedLine`.
	 * @param string
	 */
	public function parseString(string:String):Void {
		var lengthofBothArrays:Int = sequence.length;

		sequence.resize(0);
		unplayedLines.resize(0);
		elapsedLines.resize(0);

		var candidates:Array<String> = string.split("\n");
		var gotLines:Int = 0;

		for (line in candidates) {
			line = StringTools.trim(line);
			var inBrackets:String = line.substring(line.indexOf("["), line.indexOf("]"));

			if (StringTools.trim(line.indexOf("[")) != 0)
				continue;

			var timestamp:Float = SequencedLine.convertFromFormattedTime(inBrackets);

			if (timestamp == -1)
				continue;
			if (Math.isNaN(timestamp)) {
				if (line == "")
					continue;
				var split = [
					inBrackets.substring(1, inBrackets.indexOf(":")),
					inBrackets.substring(inBrackets.indexOf(":") + 1)
				];
				if (split[0] == "#")
					continue;
				extras.set(split[0], split[1]);

				if (split[0] == "offset")
					offset = Std.parseFloat(split[1]);
				continue;
			}

			var seq:SequencedLine = new SequencedLine(timestamp, StringTools.trim(line.substring(line.indexOf("]") + 1)), gotLines);

			gotLines++;

			sequence.push(seq);
			unplayedLines.push(seq);
		}

		var blank:SequencedLine = new SequencedLine(0, "", -1);

		sequence.insert(0, blank);
		unplayedLines.insert(0, blank);
	}

	/**
	 * Parses the `.lrc` file in `/songs/[song]/[difficulty].lrc`.
	 *
	 * @param song The song.
	 * @param difficulty The difficulty.
	 */
	public function parseFromSong(song:String, difficulty:String):Void {
		song = song.toLowerCase();
		difficulty = difficulty.toLowerCase();

		try {
			var fileContent:String = File.getContent("./mods/" + ModsFolder.currentModFolder + '/songs/$song/$difficulty.lrc');
			parseString(fileContent);
		} catch (e:Exception) {
			trace('Can\'t find $difficulty.lrc for song $song, does it exist?');
			trace("Exception: " + e);
		}
	}

	/**
	 * Gets a `SequencedLine` at this timestamp.
	 */
	public function getLineAtTime(time:Float) {
		var ind:Int = 0;
		for (i in sequence) {
			if (i.timestamp <= time)
				ind++;
		}

		return sequence[ind];
	}

	override public function update(elapsed:Float):Void {
		for (i in sequence) {
			if ((i.timestamp + offset) < Conductor.songPosition && !i.played) {
				i.played = true;
				onLyricShow.dispatch(i);
				elapsedLines.push(unplayedLines.shift());
				linesPlayed++;
			}
		}
	}
}
