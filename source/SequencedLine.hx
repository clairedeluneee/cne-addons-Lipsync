package source;

import haxe.Exception;

/**
 * A singular line inside the parsed LRC file. Effectively just a line in the lyrics.
 */
class SequencedLine {
	public var timestamp:Float = 0;
	public var content:String = "";
	public var played:Bool = false;
	public var id:Int = 0;

	public function new(ts:Float, ct:String, id:Int) {
		this.timestamp = ts;
		this.content = ct;
		this.id = id;
	}

	/**
	 * Converts a string in the MM:SS.ss format to a usable Float.
	 *
	 * Returns -1 if the string is invalid.
	 * @param string
	 * @return Float
	 */
	public static function convertFromFormattedTime(string:String):Float {
		var output:Float = 0;

		try {
			output = Std.parseFloat(string.substring(1, string.indexOf(":"))) * 60;
			output += Std.parseFloat(string.substring(string.indexOf(":") + 1));

			output *= 1000;
		} catch (e:Exception) {
			Logs.warn('Invalid string; cannot parse $string');
			return -1;
		}

		return output;
	}
}
