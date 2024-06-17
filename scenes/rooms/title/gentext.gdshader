shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform bool invert = false;

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE , vec2(20,17));
	COLOR.rgb = vec3(1.0 - color.rgb);
	vec3 greyScale = vec3(.5, .5, .5);
	COLOR.rgb = color.rgb;
}