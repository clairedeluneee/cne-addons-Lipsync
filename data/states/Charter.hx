import source.ClefUtils;
import source.LyricHandler;
import source.SequencedLine;
import funkin.editors.charter.Charter;
import funkin.editors.ui.UITopMenu;
import flixel.FlxG;

var lrc:LyricHandler = new LyricHandler();
var lyrPreviousLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCurrentLine:FunkinText = ClefUtils.makeText(4, 4, "", 16);
var lyrNextLine:FunkinText = ClefUtils.makeText(4, 4, "", 12);
var lyrCamera:HudCamera = ClefUtils.makeCamera(true);
var liveReload:Bool = true;
var toggled:Bool = true;
var progress:Float = 0;
var lastIdPlayed = -2;

var topMenuShit:Array<Dynamic> = [
	null,
	{
		label: "Show lyrics preview",
		onSelect: function(d) {
			toggled = !toggled;
			topMenu[3].childs[topMenu[3].childs.indexOf(topMenuShit[1])].icon = toggled ? 1 : 0;
		},
		icon: 1,
	},
	{
		label: "Live reload",
		onSelect: function(d) {
			liveReload = !liveReload;
			topMenu[3].childs[topMenu[3].childs.indexOf(topMenuShit[2])].icon = liveReload ? 1 : 0;
		},
		icon: 1,
	}
];

function postCreate() {
	for (i in [lyrPreviousLine, lyrCurrentLine, lyrNextLine]) {
		i.font = Paths.font("zh-cn.ttf");
		insert(0, i).camera = lyrCamera;
	}

	lyrNextLine.color = lyrPreviousLine.color = 0xff888888;

	lrc.parseFromSong(Charter.__song, Charter.__diff);

	for (i in topMenuShit) {
		topMenu[3].childs.push(i);
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

function toggle() {
	toggled = !toggled;
}

function postUpdate(delta) {
	var atTimestamp:SequencedLine = lrc.sequence[lrc.getLineAtTime(Conductor.songPosition).id];

	if (atTimestamp.id != lastIdPlayed) {
		lyrCurrentLine.y += lyrCurrentLine.height * (atTimestamp.id - lastIdPlayed < 0 ? -1 : 1);
	}
	lastIdPlayed = atTimestamp.id;

	lyrCurrentLine.text = atTimestamp.content;
	lyrCurrentLine.y = CoolUtil.fpsLerp(lyrCurrentLine.y, uiCamera.height / 2 - lyrCurrentLine.height / 2, 0.2);

	if (FlxG.keys.justPressed.L) {
		toggle();
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
