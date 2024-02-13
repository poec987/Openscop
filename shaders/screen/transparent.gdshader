shader_type canvas_item;
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
uniform vec4 modulate_color : source_color = vec4(1.0);
uniform vec4 transparent_color : source_color = vec4(1.0,0.0,1.0,1.0);

void fragment()
{
	vec2 texture_uv = UV;
	vec4 texture_color = texture(albedoTex, texture_uv);
	COLOR = (texture_color*modulate_color);
	if (length(texture_color - transparent_color) < 0.1)
		COLOR.a = 0.0;
}

