import source.ClefUtils;
import source.LyricHandler;
import source.SequencedLine;
import funkin.editors.charter.Charter;
import funkin.editors.ui.UITopMenu;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

var lrc:LyricHandler = new LyricHandler();
var lyrPreviousLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCurrentLine:FunkinText = ClefUtils.makeText(4, 4, "", 16);
var lyrNextLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCamera:HudCamera = ClefUtils.makeCamera(true);
var liveReload:Bool = true;
var toggled:Bool = true;
var progress:Float = 0;
var lastIdPlayed = -2;

var topMenu_ViewShit:Array<Dynamic> = [
	null,
	{
		label: "Show lyrics preview",
		onSelect: function(d) {
			toggled = !toggled;
			topMenu[3].childs[topMenu[3].childs.indexOf(topMenu_ViewShit[1])].icon = toggled ? 1 : 0;
		},
		icon: 1,
		keybind: [FlxKey.L]
	},
];

var topMenu_EditShit:Array<Dynamic> = [
	null,
	{
		label: "Seek to previous line",
		onSelect: function(d) {
			if (lrc.sequence(lrc.sequence.indexOf(lrc.currentLine) - 2) != null) {
				Conductor.songPosition = lrc.currentLine.timestamp;
			}
		},
		keybind: [FlxKey.CONTROL, FlxKey.LEFT]
	},
	{
		label: "Seek to current line",
		onSelect: function(d) {
			if (lrc.currentLine != null) {
				Conductor.songPosition = lrc.currentLine.timestamp;
			}
		},
		keybind: [FlxKey.CONTROL, FlxKey.SPACE]
	},
	{
		label: "Seek to next line",
		onSelect: function(d) {
			if (lrc.unplayedLines[0] != null) {
				Conductor.songPosition = lrc.unplayedLines[0].timestamp;
			}
		},
		keybind: [FlxKey.CONTROL, FlxKey.RIGHT]
	},
	null,
	{
		label: "Live reparse",
		onSelect: function(d) {
			liveReload = !liveReload;
			topMenu[1].childs[topMenu[1].childs.indexOf(topMenu_ViewShit[3])].icon = liveReload ? 1 : 0;
		},
		icon: 1
	},
	{
		label: "Reparse now",
		onSelect: function(d) {
			trace("Reparsing...");
			lrc.parseFromSong(Charter.__song, Charter.__diff);
		},
		keybind: [FlxKey.CONTROL, FlxKey.R]
	},
];

function postCreate() {
	for (i in [lyrPreviousLine, lyrCurrentLine, lyrNextLine]) {
		i.font = Paths.font("zh-cn.ttf");
		insert(0, i).camera = lyrCamera;
	}

	lyrNextLine.color = lyrPreviousLine.color = 0xff888888;

	lrc.parseFromSong(Charter.__song, Charter.__diff);

	for (i in topMenu_ViewShit) {
		topMenu[3].childs.push(i);
	}

	for (i in topMenu_EditShit) {
		topMenu[1].childs.push(i);
	}
}

function onFocus() {
	if (!liveReload)
		return;
	trace("Reparsing...");
	lrc.parseFromSong(Charter.__song, Charter.__diff);
}

function update(delta) {
	lrc.update(delta);
}

function postUpdate(delta) {
	progress += delta * 2.5 * (toggled ? 1 : -1);

	if (progress > 1)
		progress = 1;
	if (progress < 0)
		progress = 0;

	for (i in [lyrPreviousLine, lyrCurrentLine, lyrNextLine]) {
		i.alpha = progress;
		i.x = 4 - FlxEase.backIn(1 - progress) * 16;
	}

	var atTimestamp:SequencedLine = lrc.sequence[lrc.getLineAtTime(Conductor.songPosition)?.id] ?? lrc.sequence[lrc.sequence.length - 1];

	if (atTimestamp.id != lastIdPlayed) {
		lyrCurrentLine.y += lyrCurrentLine.height * (atTimestamp.id - lastIdPlayed < 0 ? -1 : 1);
	}
	lastIdPlayed = atTimestamp.id;

	lyrCurrentLine.text = atTimestamp.content;
	lyrCurrentLine.y = CoolUtil.fpsLerp(lyrCurrentLine.y, uiCamera.height / 2 - lyrCurrentLine.height / 2, 0.2);
}

function draw() {
	var startAt:Int = lrc.getLineAtTime(Conductor.songPosition)?.id ?? -1;
	var linesGone:Int = 0;
	var renderLimit:Int = 8;

	lyrNextLine.text = "";
	lyrNextLine.y = lyrCurrentLine.y + lyrCurrentLine.height - 16;

	for (i in 0...lrc.sequence.length) {
		if (startAt < i) {
			if (startAt == -1)
				continue;
			lyrNextLine.text += "\n" + lrc.sequence[i].content;
			linesGone++;

			if (linesGone > renderLimit || (startAt + linesGone) > lrc.sequence.length - 1)
				break;
		}
	}
	linesGone = 0;

	lyrPreviousLine.text = "";
	for (i in (startAt - renderLimit)...startAt) {
		if (i < 0 || startAt == -1)
			continue;
		lyrPreviousLine.text += "\n" + lrc.sequence[i].content ?? "";
	}
	lyrPreviousLine.y = lyrCurrentLine.y - lyrPreviousLine.height;
}
