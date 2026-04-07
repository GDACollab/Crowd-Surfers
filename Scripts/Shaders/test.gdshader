shader_type spatial;
uniform sampler2D tex: source_color;
uniform vec3 player_view_pos;


void fragment() {
	float alpha = 1.0;
	if (player_view_pos.y < NODE_POSITION_VIEW.y) {
		alpha = 0.5;
	}
	
	vec4 color = texture(tex, UV);
	ALPHA = alpha * color.a;
	ALBEDO = vec3(color.r, color.g, color.b);
}