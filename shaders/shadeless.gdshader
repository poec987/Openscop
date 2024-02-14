shader_type spatial;
render_mode unshaded, shadows_disabled;
global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
uniform vec4 modulate_color: source_color = vec4(1.0,0.0,1.0,1.0);
uniform vec4 transparent_color : source_color = vec4(1.0,0.0,1.0,1.0);
uniform bool billboard = false;
varying vec3 world_vertex;
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
const vec2 base_snap_res = vec2(160.0, 120.0);
vec4 get_snapped_pos(vec4 base_pos) {
	vec4 snapped_pos = base_pos;
	snapped_pos.xyz = base_pos.xyz / base_pos.w; // convert to normalised device coordinates (NDC)
	vec2 snap_res = floor(base_snap_res * precision_multiplier);  // increase "snappy-ness"
	snapped_pos.x = floor(snap_res.x * snapped_pos.x) / snap_res.x;  // snap the base_pos to the lower-vertex_resolution grid
	snapped_pos.y = floor(snap_res.y * snapped_pos.y) / snap_res.y;
	snapped_pos.xyz *= base_pos.w;  // convert back to projection-space
	return snapped_pos;
}

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
}

void fragment() {
	vec4 texture_color = texture(albedoTex, UV);
	ALBEDO = (texture_color*modulate_color).rgb;
	if (length(texture_color - transparent_color) < 0.1)
		ALPHA = 0.0;
}