package;

import flixel.system.FlxAssets.FlxShader;

class VCRMario85 extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{
	@glFragmentSource('
  #pragma header

  void main() {
      float red =  texture(bitmap, vec2(openfl_TextureCoordv.x - 0.003, openfl_TextureCoordv.y)).r;
    float green = texture(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y)).g;
    float blue = texture(bitmap, vec2(openfl_TextureCoordv.x + 0.003, openfl_TextureCoordv.y)).b;
      float alpha = texture(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y)).a;

      vec3 color = vec3(red, green, blue);
      gl_FragColor = vec4(color, alpha);
  }
  ')
	public function new()
	{
		super();
	}
}
