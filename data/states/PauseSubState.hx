package;

import source.ClefUtils;
import source.SequencedLine;
import source.LyricHandler;

var lrc = new LyricHandler();
var lemeta:FunkinText;
function postCreate() {
    lrc.parseFromSong(PlayState.SONG.meta.name, PlayState.difficulty);
    
    lemeta  = ClefUtils.makeText(32, 32, "meow", 16, "right", true);

    lemeta.text =         lrc.extras["ti"] ?? "?";
    lemeta.text += "\nby" + lrc.extras["ar"] ?? "?";
    lemeta.text += "\nfrom" + lrc.extras["al"] ?? "?";

    lemeta.x = window.width - 16 - lemeta.width;
    lemeta.y = window.height - 16 - lemeta.height;
    add(lemeta);
}