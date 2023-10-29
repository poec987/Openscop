shader_type spatial;
global uniform vec4 fog_color;
uniform vec4 modulate_color: source_color;
uniform vec4 transparent_color : source_color = vec4(1.0,0.0,1.0,1.0);
global uniform float sphere_size;
global uniform vec3 player_pos;
varying vec3 world_vertex;
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float min_dist = length(player_pos - world_vertex);
	float fog_func = ( 1.0 - clamp(min_dist/sphere_size, 0.0, 1.0) );
	COLOR = vec4( fog_func, fog_func, fog_func, 1.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*2.0, INV_VIEW_MATRIX[1]*2.0, INV_VIEW_MATRIX[2]*2.0, MODEL_MATRIX[3]);
}

void fragment() {
	vec4 texture_color = texture(albedoTex, UV);
	ALBEDO = mix(fog_color,(texture_color*modulate_color), COLOR.r).rgb;
	if (length(texture_color - transparent_color) < 0.1)
		ALPHA = 0.0;
}
