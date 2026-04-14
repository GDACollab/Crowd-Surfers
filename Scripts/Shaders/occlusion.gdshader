shader_type spatial;
uniform sampler2D tex: source_color;
global uniform vec3 player_view_pos;

void fragment() {
	float alpha = 1.0F;
	vec4 player_world_pos = INV_VIEW_MATRIX * vec4(player_view_pos, 1.0f);
	if(distance(NODE_POSITION_WORLD, player_world_pos.xyz) < 125.0f 
		&& NODE_POSITION_WORLD.z > player_world_pos.z 
		&& distance(VERTEX.y, player_view_pos.y) < 25.0f
		&& distance(VERTEX.x, player_view_pos.x) < 125.0f) {
		alpha = 0.1f;
	}
	
	vec4 color = texture(tex, UV);
	ALPHA = alpha * color.a;
	ALBEDO = vec3(color.r, color.g, color.b);
}