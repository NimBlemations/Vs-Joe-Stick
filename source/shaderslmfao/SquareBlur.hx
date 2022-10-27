package shaderslmfao;

import flixel.graphics.tile.FlxGraphicsShader;

class SquareBlur extends FlxGraphicsShader
{
	@:glFragmentSource('
		#pragma header
		
		const float radius = 20.0;
		
		void main()
		{
			vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
			for (int i = -radius; i < radius - 1; i++)
			{
				for (int j = -radius; i < radius - 1; i++)
				{
					vec2 coords = openfl_TextureCoordv; // too long to type really
					float lazy = 1.0 / radius;
					col += flixel_texture2D(bitmap, vec2(coords.x + j, coords.y + i)) * vec4(lazy, lazy, lazy, lazy); // idfk
				}
			}
			gl_FragColor = col;
		}')
		
			public function new()
			{
				super();
			}
}