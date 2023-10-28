shader_type spatial;
uniform vec4 fog_color : source_color;
global uniform float sphere_size;
global uniform vec3 player_pos;
varying vec3 world_vertex;

void vertex()
{
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float min_dist = length(player_pos - world_vertex);
	float fog_func = ( 1.0 - clamp(min_dist/sphere_size, 0.0, 1.0) );
	COLOR = vec4( fog_func, fog_func, fog_func, 1.0);
}

void fragment(){
	ALBEDO = COLOR.rgb;
}
