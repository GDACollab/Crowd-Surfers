shader_type spatial;
uniform sampler2D tex: source_color;
global uniform vec3 transparency_window_pos;
global uniform vec2 transparency_window_scale;

void fragment() {
	float alpha = 1.0f;
	vec3 top_left = transparency_window_pos - vec3(transparency_window_scale, 0.0f);
	vec3 bottom_right = transparency_window_pos + vec3(transparency_window_scale, 0.0f);
	vec4 top_left_view = VIEW_MATRIX * vec4(top_left, 1.0f);
	vec4 bottom_right_view = VIEW_MATRIX * vec4(bottom_right, 1.0f);
	//Check fragment inside transparency region
	if(NODE_POSITION_WORLD.z > top_left.z
		&& VERTEX.y >= top_left_view.y 
		&& VERTEX.y <= bottom_right_view.y
		&& VERTEX.x >= top_left_view.x 
		&& VERTEX.x <= bottom_right_view.x) 
	{
		alpha = 0.1f;
	}
	
	vec4 color = texture(tex, UV);
	ALPHA = alpha * color.a;
	ALBEDO = color.rgb;
}