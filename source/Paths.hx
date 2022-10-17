package;

import flixel.FlxG;
#if MEMORY_OPTIMIZATION
import flixel.graphics.FlxGraphic;
#end
import flixel.graphics.frames.FlxAtlasFrames;
#if MEMORY_OPTIMIZATION
import lime.utils.Assets;
import openfl.display3D.textures.Texture;
import openfl.display.BitmapData;
import openfl.media.Sound;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if MEMORY_OPTIMIZATION
import openfl.system.System;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	#if MEMORY_OPTIMIZATION
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
		openfl.Assets.cache.clear("songs");
	}
	
	public static function returnGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		trace(path);
		if (OpenFlAssets.exists(path, IMAGE))
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
					newGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					trace('new bitmap $key, not textured');
				}
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
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
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath(gottenPath, SOUND, library)));
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}
	#end

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = "";
			if (currentLevel != "shared") {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

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
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
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
		#if MEMORY_OPTIMIZATION
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
		#else
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		#end
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if MEMORY_OPTIMIZATION
		var file:Sound = returnSound('music', key, library);
		return file;
		#else
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
		#end
	}

	inline static public function voices(song:String):Any
	{
		#if MEMORY_OPTIMIZATION
		var songKey:String = '${song.toLowerCase()}/Voices.$SOUND_EXT';
		var voices = returnSound('songs', songKey);
		return voices;
		#else
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		#end
	}

	inline static public function inst(song:String):Any
	{
		#if MEMORY_OPTIMIZATION
		var songKey:String = '${song.toLowerCase()}/Inst.$SOUND_EXT';
		var inst = returnSound('songs', songKey);
		return inst;
		#else
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		#end
	}

	inline static public function image(key:String, ?library:String, ?textureCompression:Bool = false)
	{
		#if MEMORY_OPTIMIZATION
		var returnAsset:FlxGraphic = returnGraphic(key, library, textureCompression);
		return returnAsset;
		#else
		return getPath('images/$key.png', IMAGE, library);
		#end
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
		#if MEMORY_OPTIMIZATION
		var graphic:FlxGraphic = returnGraphic(key, library);
		return FlxAtlasFrames.fromSparrow(graphic, file('images/$key.xml', library));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
