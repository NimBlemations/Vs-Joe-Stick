package shaderslmfao;

import flixel.FlxSprite;

class AngleLighting
{
	public var shader(default, null):AngleLightingShader = new AngleLightingShader();
	
	public var selfLight:Float = 0.75;
	public var lightAmount:Float = 1.25;
	public var angle:Float = 1.0;
	public var simple:Bool = true;
	
	public function new():Void
	{
		shader.selfLight.value = [selfLight];
		
		shader.lightAmount.value = [lightAmount];
		
		shader.angle.value = [angle];
		
		shader.simple.value = [simple];
	}
}