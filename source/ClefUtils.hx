package source;

/**
 * Various utilities Claire uses in her scripts.
 * 
 * This is a parallel to her `base.lua` script for Psych 0.7.3, just in Codename HScript.
 */
class ClefUtils {
    /**
     * Creates a rectangle of a specified size at the specified coordinates.
     */
    public static function makeRect(x, y, w, h, col):FlxSprite {
        s = new FlxSprite(x,y).makeGraphic(w,h,col);
        return s;
    }

    /**
     * Creates a text of a specified size with a specified text at the specified coordinates.
     */
    public static function makeText(x, y, str = "", size = 16, align = "left", outline = true):FunkinText {
        var t = new FunkinText(x, y, 0, str, size, outline);
        t.antialiasing = Options.antialiasing;
        t.alignment = align;
        return t;
    }

    /**
     * Creates a camera. There's nothing much else to it.
     * @param autoAdd Should this camera be automatically added to `FlxG.cameras`?
     */
    public static function makeCamera(autoAdd:Bool = false):HudCamera {
        cam = new HudCamera();
        cam.bgColor = 0x00000000;
        if (autoAdd) FlxG.cameras.add(cam, false);
        return cam;
    }

    /**
     * Extracts the RGB components for a color in the 0xRRGGBB format.
     * @param color 
     * @return Array<Int>
     */
    function extractRgbChannels(color:Int):Array<Int> {
        return [(color >> 16 & 0xff), (color >> 8) & 0xff, color & 0xff];
    }


}