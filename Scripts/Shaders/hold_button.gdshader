shader_type canvas_item;

uniform float hold_progress = 0.0;
uniform float brightness = 0.2;

void fragment() {
	if (COLOR.a < 0.1) {discard;}
	
	bool bright = UV.x < hold_progress;
	float bright_factor = 0.0;
	if (bright) {bright_factor = brightness;}
	COLOR += vec4(vec3(bright_factor), 1.0);
}
