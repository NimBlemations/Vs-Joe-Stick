package shaderslmfao;

class Blur
{
	public var shader(default, null):BlurShader = new BlurShader();
	public var radius:Float = 8.0;
	
	public function new()
	{
		shader.Size.value = [0.0];
	}
	
	public function update()
	{
		shader.Size.value = [radius];
	}
}