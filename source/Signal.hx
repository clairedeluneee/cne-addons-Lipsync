package source;

/**
 * `FlxSignal` workaround.
 */
class Signal {

    var funcs:Array<Dynamic> = [];

    public function dispatch(params):Void {
        for (i in funcs) i(params);
    }

    public function add(dyn) {
        funcs.push(dyn);
    }
}