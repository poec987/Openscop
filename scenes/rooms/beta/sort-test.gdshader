shader_type spatial;
render_mode shadows_disabled;

global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
uniform float depth_offset = 0.0;

const vec2 base_snap_res = vec2(160.0, 120.0);
vec4 get_snapped_pos(vec4 base_pos)
{
	vec4 snapped_pos = base_pos;
	snapped_pos.xyz = base_pos.xyz / base_pos.w; // convert to normalised device coordinates (NDC)
	vec2 snap_res = floor(base_snap_res * precision_multiplier);  // increase "snappy-ness"
	snapped_pos.x = floor(snap_res.x * snapped_pos.x) / snap_res.x;  // snap the base_pos to the lower-vertex_resolution grid
	snapped_pos.y = floor(snap_res.y * snapped_pos.y) / snap_res.y;
	snapped_pos.xyz *= base_pos.w;  // convert back to projection-space
	return snapped_pos;
}
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform vec2 uv_pan_velocity = vec2(0.0);
void vertex()
{
#if !defined(NO_TEXTURE) && !defined(METAL)  // METAL doesn't use UV, so no need to pan UVs
	UV = UV * uv_scale + uv_offset;
	UV += uv_pan_velocity * TIME;
#endif

	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping

	VERTEX = VERTEX;  // it breaks without this - not sure why
	vec3 world_position = vec4(MODEL_MATRIX * vec4(VERTEX,1)).xyz;
	//set direction vector from vertex to camera in world space
	vec3 dir2cam  = normalize(CAMERA_POSITION_WORLD - world_position);
	//offset depth by world(global) units.
	world_position += dir2cam * depth_offset;
	//transform world_position back to model(local, object) space and set vertex position.
	VERTEX = vec4(inverse(MODEL_MATRIX) * vec4(world_position,1)).xyz;
}

void fragment()
{
	ALBEDO = COLOR.rgb;
	vec2 texture_uv = UV;
	vec4 texture_color = texture(albedoTex, texture_uv);
	ALBEDO = texture_color.rgb;
	vec3 world_position = vec4(INV_VIEW_MATRIX * vec4(VERTEX,1)).xyz;
	//set direction fragment from vertex to camera in world space
	vec3 dir2cam  = normalize(CAMERA_POSITION_WORLD - world_position);
	//move fragment towards camera in world(global) space
	world_position += dir2cam * depth_offset;
	//transform world_position from world(global) to view space
	//then transform world_position from view to clip(ndc) space
	vec4 ndc_offset = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_position,1);
	//normalize ndc_offset.z and set depth
	DEPTH = ndc_offset.z/ndc_offset.w;

}

