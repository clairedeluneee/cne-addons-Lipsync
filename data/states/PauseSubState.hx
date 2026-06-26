package;

import StringTools;
import source.ClefUtils;
import source.SequencedLine;
import source.LyricHandler;

var lrc = new LyricHandler();
var lemeta:FunkinText;

function postCreate() {
	lrc.parseFromSong(PlayState.SONG.meta.name, PlayState.difficulty);

	if (lrc.extras.length == 0)
		disableScript();

	lemeta = ClefUtils.makeText(32, 32, "meow", 24, "right", true);

	lemeta.text = StringTools.trim(lrc.extras["ti"]) ?? "?";
	lemeta.text += "\nby " + StringTools.trim(lrc.extras["ar"]) ?? "?";
	lemeta.text += "\nfrom " + StringTools.trim(lrc.extras["al"]) ?? "?";

	lemeta.x = window.width - 24 - lemeta.width;
	lemeta.y = window.height - 24 - lemeta.height;
	add(lemeta);
}
