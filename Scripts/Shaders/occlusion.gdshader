shader_type spatial;
uniform sampler2D tex: source_color;
global uniform vec3 player_view_pos;

void fragment() {
	float alpha = 1.0F;
	vec4 player_world_pos = INV_VIEW_MATRIX * vec4(player_view_pos, 1.0f);
	//vec4 player_clip_pos = PROJECTION_MATRIX * vec4(player_view_pos, 1.0f);
	
	//if (distance(VERTEX.y, player_view_pos.y) < 25.0f && player_view_pos.z < FRAGCOORD.z) {
		//alpha = 0.1;
	//}
	if(NODE_POSITION_WORLD.z > player_world_pos.z 
		&& distance(VERTEX.y, player_view_pos.y) < 25.0f
		&& distance(VERTEX.x, player_view_pos.x) < 125.0f) {
		alpha = 0.1f;
	}
	//if(NODE_POSITION_VIEW.z < player_view_pos.z) alpha = 0.1f;
	//if(FRAGCOORD.z > player_clip_pos.z) alpha = 0.1f;
	
	vec4 color = texture(tex, UV);
	ALPHA = alpha * color.a;
	ALBEDO = vec3(color.r, color.g, color.b);
}