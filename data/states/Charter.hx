import source.ClefUtils;
import source.LyricHandler;
import source.SequencedLine;
import funkin.editors.charter.Charter;
import flixel.FlxG;

var lrc:LyricHandler = new LyricHandler();
var lyrPreviousLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCurrentLine:FunkinText = ClefUtils.makeText(4, 4, "", 16);
var lyrNextLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCamera:HudCamera = ClefUtils.makeCamera(true);

function postCreate() {
	for (i in [lyrPreviousLine, lyrCurrentLine, lyrNextLine]) {
		i.font = Paths.font("zh-cn.ttf");
		insert(0, i).camera = lyrCamera;
	}

	lyrNextLine.color = lyrPreviousLine.color = 0xff888888;

	lrc.parseFromSong(Charter.__song, Charter.__diff);
}

function onFocus() {
	trace("Reparsing...");
	lrc.parseFromSong(Charter.__song, Charter.__diff);
}

function update(delta) {
	lrc.update(delta);
}

var toggled:Bool = true;
var progress:Float = 0;

function postUpdate(delta) {
	var atTimestamp:SequencedLine = lrc.sequence[lrc.getLineAtTime(Conductor.songPosition).id];
	lyrCurrentLine.text = atTimestamp.content;
	lyrCurrentLine.y = uiCamera.height / 2 - lyrCurrentLine.height / 2;

	if (FlxG.keys.justPressed.L) {
		toggled = !toggled;
	}

	progress += delta * 2.5 * (toggled ? 1 : -1);

	if (progress > 1)
		progress = 1;
	if (progress < 0)
		progress = 0;

	for (i in [lyrPreviousLine, lyrCurrentLine, lyrNextLine]) {
		i.alpha = progress;
		i.x = 4 - FlxEase.backIn(1 - progress) * 16;
	}
}

function draw() {
	var startAt:Int = lrc.getLineAtTime(Conductor.songPosition).id;
	var linesGone:Int = 0;
	var renderLimit:Int = 8;

	lyrNextLine.text = "";
	lyrNextLine.y = lyrCurrentLine.y + lyrCurrentLine.height - 16;

	for (i in 0...lrc.sequence.length) {
		if (startAt < i) {
			lyrNextLine.text += "\n" + lrc.sequence[i].content;
			linesGone++;

			if (linesGone > renderLimit || (startAt + linesGone) > lrc.sequence.length - 1)
				break;
		}
	}
	linesGone = 0;

	lyrPreviousLine.text = "";
	for (i in (startAt - renderLimit)...startAt) {
		if (i < 0)
			continue;
		lyrPreviousLine.text += "\n" + lrc.sequence[i].content ?? "";
	}
	lyrPreviousLine.y = lyrCurrentLine.y - lyrPreviousLine.height;
}
