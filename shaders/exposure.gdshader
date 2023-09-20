shader_type canvas_item;
#pragma disable_preprocessor

uniform float exposure = 1.0;
uniform bool enabled = true;

void fragment()
{
	if (enabled)
		 COLOR = texture(TEXTURE, UV) * exposure;
    else 
		COLOR = texture(TEXTURE, UV);
}
