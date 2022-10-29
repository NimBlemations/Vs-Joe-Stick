package;

// With the conditionals, I just want to not leave ANYTHING unnecessary behind on compile, but the flags are getting ridiculous, I know.

#if MEMORY_OPTIMIZATION
import flash.geom.Rectangle;
#end
import flixel.FlxG;
#if MEMORY_OPTIMIZATION
import flixel.graphics.FlxGraphic;
#end
import flixel.graphics.frames.FlxAtlasFrames;
#if MEMORY_OPTIMIZATION
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.xml.Access;
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

#if MEMORY_OPTIMIZATION
using StringTools;
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
				@:privateAccess
				if (obj != null)
				{
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
			counter++;
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
	
	public static function returnGraphic(key:String, ?library:String)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		// trace(path);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				if (!currentTrackedAssets.exists(path))
				{
					var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					currentTrackedAssets.set(path, newGraphic);
				}
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		trace('oh no $key is returning null NOOOO');
		return null;
	}
	
	public static function returnSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if (path == 'songs')
				folder = 'songs:';
			
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}
	
	public static function preloadSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if (path == 'songs')
				folder = 'songs:';
			
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
	}
	#end
	
	public static function preloadGraphic(key:String, ?library:String, ?packXml:Bool = false)
	{
		#if MEMORY_OPTIMIZATION
		var path = getPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				if (!currentTrackedAssets.exists(path))
				{
					trace('preloading $key');
					var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					currentTrackedAssets.set(path, newGraphic);
					if (packXml) // This shit is fuckin' broken, don't know what's going wrong and I am too unbothered to persue
					{
						var xmlPath = getPath('images/$key.xml', TEXT, library);
						#if debug
						trace(xmlPath);
						#end
						if (OpenFlAssets.exists(xmlPath))
						{
							if (key.endsWith('s'))
								trace('preloading ${key}\' xml');
							else
								trace('preloading ${key}\'s xml');
							var xmlText = OpenFlAssets.getText(xmlPath);
							var frameArray:Array<FlxFrame> = [];
							var xmlAccess:Access = new Access(Xml.parse(xmlText).firstElement());
							
							@:privateAccess
							for (texture in xmlAccess.nodes.SubTexture) // For all of this, go to https://github.com/HaxeFlixel/flixel/blob/master/flixel/graphics/frames/FlxAtlasFrames.hx
							{
								var name = texture.att.name;
								var trimmed = texture.has.frameX;
								var rotated = (texture.has.rotated && texture.att.rotated == "true");
								var flipX = (texture.has.flipX && texture.att.flipX == "true");
								var flipY = (texture.has.flipY && texture.att.flipY == "true");
								
								var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), 
									Std.parseFloat(texture.att.height));
								
								var size = if (trimmed)
								{
									new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
										Std.parseInt(texture.att.frameHeight));
								}
								else
								{
									new Rectangle(0, 0, rect.width, rect.height);
								}
								
								var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
								
								var offset = FlxPoint.get( -size.left, -size.top);
								var sourceSize = FlxPoint.get(size.width, size.height);
								
								if (rotated && !trimmed)
									sourceSize.set(size.height, size.width);
								
								var xmlFrame:FlxFrame = new FlxFrame(newGraphic, angle, flipX, flipY);
								
								xmlFrame.frame = rect;
								xmlFrame.name = name;
								
								frameArray.push(xmlFrame);
							}
							
							var xmlCollection:FlxFramesCollection = new FlxFramesCollection(newGraphic, FlxFrameCollectionType.ATLAS);
							
							newGraphic.addFrameCollection(xmlCollection); // Fuckin' wild ride that was...
						}
					}
				}
			}
		}
		else
			trace('oh no $key is null NOOOO');
		#else
		trace('penis ($key $library)');
		#end
	}
	
	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared') {
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

	static public function sound(key:String, ?library:String) #if MEMORY_OPTIMIZATION :Sound #end
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

	inline static public function music(key:String, ?library:String) #if MEMORY_OPTIMIZATION :Sound #end
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
		var songKey:String = '${song.toLowerCase()}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
		#else
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		#end
	}

	inline static public function inst(song:String):Any
	{
		#if MEMORY_OPTIMIZATION
		var songKey:String = '${song.toLowerCase()}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#else
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		#end
	}

	inline static public function image(key:String, ?library:String) #if MEMORY_OPTIMIZATION :FlxGraphic #end
	{
		#if MEMORY_OPTIMIZATION
		var returnAsset:FlxGraphic = returnGraphic(key, library);
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
