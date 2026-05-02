shader_type spatial;

render_mode depth_prepass_alpha; 

global uniform vec3 transparency_window_pos;
global uniform vec2 transparency_window_scale;
global uniform vec3 player_pos;
global uniform float alpha_amount;

uniform sampler2D tex: source_color;

instance uniform bool do_transparency = true;
instance uniform float object_back_depth = 0.0f;

const mat4 THRESHOLD_MATRIX = mat4(
		vec4(1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
		vec4(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
		vec4(4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
		vec4(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0));
		
void fragment() {
	float alpha = 1.0f;
		
	if(do_transparency) {
		// Get coordinates of the transparency window in world space
		vec3 top_left = transparency_window_pos - vec3(transparency_window_scale, 0.0f);
		vec3 bottom_right = transparency_window_pos + vec3(transparency_window_scale, 0.0f);
		// Transition these coordinates into view space
		vec4 top_left_view = VIEW_MATRIX * vec4(top_left, 1.0f);
		vec4 bottom_right_view = VIEW_MATRIX * vec4(bottom_right, 1.0f);
		//Check fragment inside transparency region
		if(object_back_depth >= player_pos.z
			&& VERTEX.y >= top_left_view.y 
			&& VERTEX.y <= bottom_right_view.y
			&& VERTEX.x >= top_left_view.x 
			&& VERTEX.x <= bottom_right_view.x) 
		{
			alpha = alpha_amount;
		}
	}
	
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	vec4 color = texture(tex, UV);
	// Create the dithering pattern for the transparency window
	ALPHA = color.a * step(0.0, THRESHOLD_MATRIX[int(FRAGCOORD.x) % 4][int(FRAGCOORD.y) % 4] - (1.0f - alpha));
	ALBEDO = color.rgb;
}
