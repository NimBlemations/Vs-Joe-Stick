package shaderslmfao;

import flixel.graphics.tile.FlxGraphicsShader;

class AngleLightingShader extends FlxGraphicsShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float selfLight;
		
		uniform float lightAmount;
		
		uniform float angle;
		
		uniform bool simple;
		
		void main()
		{
			vec2 normalCoords = vec2(sin(angle) * 10, cos(angle * 2) * 10);
			vec2 newCoords = vec2(0, 0);
			
			if (simple)
			{
				newCoords = vec2(openfl_TextureCoordv.x + (angle * 20), openfl_TextureCoordv.y + (angle * 20));
			}
			else
			{
				newCoords = openfl_TextureCoordv + normalCoords;
			}
			
			vec4 color = texture2D(bitmap, openfl_TextureCoordv);
			
			vec4 offsetColor = texture2D(bitmap, newCoords);
			
			float light = (1.0 - offsetColor.a) * lightAmount;
			
			gl_FragColor = vec4(((color.r * selfLight) * light) * color.a, ((color.g * selfLight) * light) * color.a, ((color.b * selfLight) * light) * color.a, color.a);
		}')
		
	public function new()
	{
		super();
	}
}