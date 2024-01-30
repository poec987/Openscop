shader_type canvas_item;
uniform float gradient_power = 10.;
varying vec2 full_uv;
uniform sampler2D gradient;
//const float 
uniform float offset = 0;
void vertex(){
	full_uv = VERTEX.xy;
}

void fragment(){
	vec4 texture_color = texture(gradient, UV);
    if (COLOR.rgb!=vec3(0.,0.,0.) && COLOR.rgb!=vec3(1.,1.,1.)) {
		//COLOR.a = 1.0;
		COLOR.rgb = mix(vec3(COLOR.r/2.5,COLOR.g/2.5,COLOR.b/2.5), COLOR.rgb, fract((SCREEN_UV.y)*gradient_power+offset));
    }
}