shader_type spatial;
render_mode shadows_disabled, depth_draw_opaque;
global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
global uniform vec4 fog_color;
uniform vec4 modulate_color: source_color;
uniform vec4 transparent_color : source_color = vec4(1.0,0.0,1.0,1.0);
global uniform float sphere_size;
global uniform vec3 player_pos;
global uniform bool fog_enable;
varying vec3 world_vertex;
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
uniform bool billboard = true;
const vec2 base_snap_res = vec2(160.0, 120.0);

group_uniforms spritesheet;

	uniform bool is_spritesheet = false;
	uniform ivec2 spritesheet_size = ivec2(1, 1);
	uniform ivec2 sprite = ivec2(0, 0);
	
group_uniforms animation;
	uniform bool enable_auto_animation_x = false;
	uniform bool enable_auto_animation_y = false;
	uniform int frame_count = 1;
	uniform int frame_offset = 0;
	uniform float animation_speed = 1.0;
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
	if(is_spritesheet)
	{
		vec2 anim_sprite = vec2(sprite);
		if(enable_auto_animation_x && frame_count != 0)
		{
			anim_sprite.x = floor(TIME * animation_speed);
			anim_sprite.x = floor(anim_sprite.x / float(frame_count) * vec2(spritesheet_size).x);
			anim_sprite.x += float(frame_offset);
		}
		else if(enable_auto_animation_y && frame_count != 0)
		{
			anim_sprite.y = floor(TIME * animation_speed);
			anim_sprite.y = floor(anim_sprite.y / float(frame_count) * vec2(spritesheet_size).y);
			anim_sprite.y += float(frame_offset);
		}
		UV = (UV + anim_sprite) / vec2(spritesheet_size);
	}
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float min_dist = length(player_pos - world_vertex);
	float fog_func = ( 0.75 - clamp((min_dist/2.)/sphere_size*2., 0.0, 1.0) );
	COLOR = vec4( fog_func, fog_func, fog_func, 1.0);
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*2.0, INV_VIEW_MATRIX[1]*2.0, INV_VIEW_MATRIX[2]*2.0, MODEL_MATRIX[3]);
	}
	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
}

void fragment() {
	vec4 texture_color = texture(albedoTex, UV);
	if (fog_enable) {
		ALBEDO = mix(fog_color,(texture_color*modulate_color), COLOR).rgb;
	} else {
		ALBEDO = (texture_color*modulate_color).rgb;
	}
	if (length(texture_color - transparent_color) < 0.1)
		ALPHA = 0.0;
}
