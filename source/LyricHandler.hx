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

    public var onLyricShow;

    public var linesPlayed:Int = 0;


    public function new(){
        super();
        onLyricShow = new Signal();
    }

    /**
     * Parses a string and turns it into `SequencedLine`.
     * @param string 
     */
    public function parseString(string:String):Void {
        var candidates:Array<String> = string.split("\n");

        for (line in candidates) {
            line = StringTools.trim(line);
            var inBrackets:String = line.substring(line.indexOf("["), line.indexOf("]"));

            var timestamp:Float = SequencedLine.convertFromFormattedTime(inBrackets);

            if (timestamp == -1) continue;
            if (Math.isNaN(timestamp)) {
                if (line == "") continue;
                
            }

            var seq:SequencedLine = new SequencedLine(timestamp, line.substring(line.indexOf("]") + 1));

            sequence.push(seq);
            unplayedLines.push(seq);
        }
    }

    /**
     * Parses the `.lrc` file in `/songs/[song]/[difficulty].lrc`.
     * 
     * @param song The song.
     * @param difficulty The difficulty.
     */
    public function parseFromSong(song:String, difficulty:String):Void {
        try {
            var fileContent:String = File.getContent("./mods/" + ModsFolder.currentModFolder + '/songs/$song/$difficulty.lrc');
            parseString(fileContent);
        } catch (e:Exception) {
            trace(e);
        }
    }

    override public function update(elapsed:Float):Void {

        for (i in sequence) {
            if (i.timestamp < Conductor.songPosition && !i.played) {
                i.played = true;
                onLyricShow.dispatch(i);
                elapsedLines.push(unplayedLines.shift());
                linesPlayed++;
            }
        }
    }


}