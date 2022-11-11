package;

import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;

/**
 * Hey, this is supposed to be lua interpreted by Haxe, this shit ain't ready yet.
 */

class BasicLua
{
	public var files:Array<String>;
	
	private var variables:Map<String, Any>;
	private var functions:Map<String, String>;
	
	private var callbacks:Map<String, Dynamic>;
	
	public function openFile(filepath:String)
	{
		if (OpenFlAssets.exists(filepath))
		{
			var file:String = Assets.getText(filepath);
			files.push(file);
		}
		else
			trace('bruh moment');
	}
}