shader_type canvas_item;
uniform float gradient_power = 10.;
uniform float offset = 1;

void fragment(){
    if (COLOR.rgb!=vec3(0.,0.,0.) && COLOR.rgb!=vec3(1.,1.,1.)) {
		//COLOR.a = 1.0;
		COLOR.rgb = mix(vec3(COLOR.r/2.5,COLOR.g/2.5,COLOR.b/2.5), COLOR.rgb, fract((SCREEN_UV.y+offset)*gradient_power+offset));
    }
	//COLOR.rgb = mix(vec3(COLOR.r/2.5,COLOR.g/2.5,COLOR.b/2.5), COLOR.rgb, fract((SCREEN_UV.y+offset)*gradient_power+offset));
}