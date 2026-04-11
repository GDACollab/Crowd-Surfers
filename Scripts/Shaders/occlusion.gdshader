shader_type spatial;
uniform sampler2D tex: source_color;
uniform vec3 player_view_pos;

void fragment() {
	float alpha = 1.0F;
	if (player_view_pos.z == 0.0F) {
		alpha = 0.1F;
	}
	//if (distance(VERTEX.xy, player_view_pos.xy) < 25.0F) {
		//alpha = 0.1;
	//}
	
	vec4 color = texture(tex, UV);
	ALPHA = alpha * color.a;
	ALBEDO = vec3(color.r, color.g, color.b);
}