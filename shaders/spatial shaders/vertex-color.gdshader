shader_type spatial;
global uniform bool allow_animation = false;
render_mode unshaded, shadows_disabled, depth_prepass_alpha, blend_mix;
#include "vertexsnapping.gdshaderinc"

varying vec3 world_vertex;
uniform bool billboard = false;
uniform bool y_billboard = false;
uniform sampler2D color_texture : source_color, filter_nearest, repeat_enable;

uniform vec4 transparent_color : source_color = vec4(1.0,0.0,1.0,1.0);
uniform vec4 tint_color : source_color = vec4(1.0,1.0,1.0,1.0);


uniform bool fog = false;
global uniform vec4 fog_color;
global uniform float sphere_size;
global uniform vec3 player_pos; 

group_uniforms uv_mofification;

	uniform vec2 uv_scale = vec2(1.0, 1.0);
	uniform vec2 uv_offset = vec2(0.0, 0.0);
	
group_uniforms advanced_vertex_colors;
	uniform bool vertex_color_as_mask = false;
	uniform bool invert = false;
	uniform bool add_blend_mode = false;
	uniform bool multiply_blend_mode = false;
	uniform vec4 masked_color : source_color = vec4(1.0,1.0,1.0,1.0);

const float alpha_scissor = 0.25;

void vertex()
{
	UV = UV * uv_scale + uv_offset;
	
	if (fog) {
		world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float min_dist = length(player_pos - world_vertex);
		float fog_func = ( 0.5 - clamp((min_dist/1.5)/sphere_size, 0.0, 1.0) );
		if (billboard){
			fog_func = ( 0.75 - clamp((min_dist/2.)/sphere_size*2., 0.0, 1.0) );
		}
		if (fog){
			COLOR = COLOR.rgba*vec4( fog_func, fog_func, fog_func, 1.0);
		}
		if (billboard) {
			MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*2.0, INV_VIEW_MATRIX[1]*2.0, INV_VIEW_MATRIX[2]*2.0, MODEL_MATRIX[3]);
		}
	}

	if (y_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], MODEL_MATRIX[1], vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, MODEL_MATRIX[1].xyz)), 0.0), MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0 / length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}
	else if (billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0]*2.0, INV_VIEW_MATRIX[1]*2.0, INV_VIEW_MATRIX[2]*2.0, MODEL_MATRIX[3]);
	}

	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping

	if (y_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}
}

void fragment()
{
	vec4 texture_color = texture(color_texture, UV);
	
	if (vertex_color_as_mask)
	{
		ALBEDO = (texture_color * tint_color).rgb;
		float mask = length(COLOR.rgb);
		if (invert)
			mask = max(1.0 - mask, 0.0);

		if (add_blend_mode && !multiply_blend_mode)
			ALBEDO = mix(ALBEDO, ALBEDO + masked_color.rgb, mask);
		else if (!add_blend_mode && multiply_blend_mode)
			ALBEDO = mix(ALBEDO, ALBEDO * masked_color.rgb, mask);
		else if (add_blend_mode && multiply_blend_mode)
			ALBEDO = mix(ALBEDO, ALBEDO * masked_color.rgb + ALBEDO, mask);
		else
			ALBEDO = mix(ALBEDO, masked_color.rgb, mask);
	}
	else
		ALBEDO = mix(fog_color,(texture_color*tint_color),COLOR).rgb;
			
	
		
	if (length(texture_color - transparent_color) < 0.1)
		ALPHA = 0.0;
	else
		ALPHA = texture_color.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}