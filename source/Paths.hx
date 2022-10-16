package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display3D.textures.Texture;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}
	
	public static var dumpExclusions:Array<String> = [
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/music/foreverMenu.$SOUND_EXT',
		'assets/music/breakfast.$SOUND_EXT',
	];
	
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					@:privateAccess
					if (openfl.Assets.cache.hasBitmapData(key))
					{
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
					}
					trace('removed $key, ' + (isTexture ? 'is a texture' : 'is not a texture'));
					obj.destroy();
					currentTrackedAssets.remove(key);
					counter++;
				}
			}
		}
		trace('removed $counter assets');
		// run the garbage collector for good measure lmfao
		System.gc();
	}
	
	public static var localTrackedAssets:Array<String> = [];
	
	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}
	
	public static function returnGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		trace(path);
		if (OpenFlAssets.exists(path, AssetType.IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				var imgPath = path;
				if (imgPath.split(":")[1] != null)
					imgPath = imgPath.split(":")[1];
				var bitmap = BitmapData.fromFile(imgPath);
				var newGraphic:FlxGraphic;
				if (textureCompression)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					trace('new texture $key, bitmap is $bitmap');
					newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
				}
				else
				{
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
					trace('new bitmap $key, not textured');
				}
				currentTrackedAssets.set(key, newGraphic);
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		trace('oh no ' + key + ' is returning null NOOOO');
		return null;
	}
	
	public static function returnSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath))
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
		localTrackedAssets.push(key);
		return currentTrackedSounds.get(gottenPath);
	}

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${song.toLowerCase()}/Voices.$SOUND_EXT';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${song.toLowerCase()}/Inst.$SOUND_EXT';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library, textureCompression);
		return returnAsset;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('music/$key.mp4', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var graphic:FlxGraphic = returnGraphic(key, library);
		return FlxAtlasFrames.fromSparrow(graphic, file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
