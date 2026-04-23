shader_type spatial;

global uniform vec3 player_pos;

uniform sampler2D tex : source_color;

void fragment() {
	//Don't apply this overlay to portions of a sprite that are already transparent
	if(abs(texture(tex, UV).a) < 0.1f) ALPHA = 0.0f;
	else {
		float alpha = 0.0f;
		//Height of the pixel in world space
		float fragment_height = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0f)).y;
		float height_diff = fragment_height - player_pos.y;
		if(height_diff > 50.0f) {
			//Transparency decreases with height, maxxing out at a difference of 100
			alpha = 0.25f * (height_diff - 50.0f) / 100.0f;
		}
		ALPHA = alpha;
		ALBEDO = vec3(0.65f, 0.91f, 0.90f);
	}
}
