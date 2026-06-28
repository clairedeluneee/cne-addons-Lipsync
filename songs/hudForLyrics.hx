package songs;

import Float;
import source.LyricHandler;
import source.SequencedLine;
import source.ClefUtils;

var lrc = new LyricHandler();
var nextLine:FunkinText = ClefUtils.makeText(16, 720 - 16 - 16, "", 12, "left", true);
var curLine:FunkinText = ClefUtils.makeText(16, 720 - 16 - 32, "", 16, "left", true);

function postCreate() {
	lrc.parseFromSong(SONG.meta.name, PlayState.difficulty);

	if (lrc.sequence.length == 0)
		disableScript();

	lrc.onLyricShow.add(lyricShow);

	add(nextLine).camera = camHUD;
	add(curLine).camera = camHUD;

	nextLine.font = curLine.font = Paths.font("zh-cn.ttf");
}

function update(elapsed:Float) {
	lrc.update(elapsed);

	curLine.y = CoolUtil.fpsLerp(curLine.y, 720 - 16 - 32, 0.125);
	curLine.x = window.width - 16 - curLine.width;
	if (lrc.unplayedLines.length > 0) {
		nextLine.alpha = 1 - Math.min(Math.floor(lrc.unplayedLines[0].timestamp - Conductor.songPosition) * 0.001, 0.5);
		nextLine.text = lrc.unplayedLines[0].content;
	}
	nextLine.x = window.width - 16 - nextLine.width;
}

function lyricShow(line:SequencedLine) {
	curLine.text = line.content;
	curLine.y = 720 - 16 - 16;
}
