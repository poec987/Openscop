shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment(){
	vec4 color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
	COLOR = vec4(1.0 - color.rgb, color.a);
	vec3 greyScale = vec3(.5, .5, .5);
    COLOR.rgb = vec3(dot(COLOR.rgb, greyScale));
	COLOR.rgb = mix(vec3(0.5), COLOR.rgb, 10.0);
}