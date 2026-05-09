shader_type spatial;

global uniform vec3 player_pos;
global uniform vec3 fog_color;
global uniform float fog_height_minimum_distance;
global uniform float fog_height_maximum_distance;
global uniform float fog_max_alpha;

uniform sampler2D tex : source_color;

void fragment() {
	//Don't apply this overlay to portions of a sprite that are already transparent
	if(abs(texture(tex, UV).a) < 0.1f) ALPHA = 0.0f;
	else {
		float alpha = 0.0f;
		//Height of the pixel in world space
		float fragment_height = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0f)).y;
		float height_diff = fragment_height - player_pos.y;
		if(height_diff > fog_height_minimum_distance) {
			//Transparency decreases with height, maxxing out at the max difference
			alpha = fog_max_alpha * min(height_diff - fog_height_minimum_distance, fog_height_maximum_distance) 
				/ fog_height_maximum_distance;
		}
		ALPHA = alpha;
		ALBEDO = fog_color;
	}
}
