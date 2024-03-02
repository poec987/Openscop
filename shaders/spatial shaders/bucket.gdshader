shader_type spatial;
render_mode shadows_disabled;

uniform vec4 tint_color : source_color = vec4(1.0,1.0,1.0,1.0);

varying vec3 world_vertex;
global uniform bool fog_enable;
global uniform vec4 fog_color;
global uniform float sphere_size;
global uniform vec3 player_pos; 
uniform bool fog = false;
void vertex() {
	if (fog_enable) {
		world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float min_dist = length(player_pos - world_vertex);
		float fog_func = ( 0.5 - clamp((min_dist/1.5)/sphere_size, 0.0, 1.0) );
		if (fog_enable){
			COLOR = COLOR.rgba*vec4( fog_func, fog_func, fog_func, 1.0);
		}
	}
}

void fragment() {
	if (fog_enable) {
	    ALBEDO = mix(vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114))), COLOR.rgb, 0.8);
		ALBEDO = mix(vec3(1.0), ALBEDO, 1.1);
		ALBEDO = ALBEDO*1.0;
	} else {
		ALBEDO = mix(vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114))), COLOR.rgb, 1.0);
		ALBEDO = mix(vec3(1.0), ALBEDO, 1.35);
		ALBEDO = ALBEDO*0.65;
	}
}