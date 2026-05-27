shader_type spatial;

render_mode depth_prepass_alpha, cull_disabled;

uniform sampler2D tex : source_color;
uniform float alpha_amount : hint_range(0.0, 1.0) = 1.0;

const mat4 THRESHOLD_MATRIX = mat4(
	vec4(1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0),
	vec4(13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0),
	vec4(4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0),
	vec4(16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0)
);

void fragment() {
	vec4 color = texture(tex, UV);

	float threshold = THRESHOLD_MATRIX[int(FRAGCOORD.x) % 4][int(FRAGCOORD.y) % 4];
	float dither = step(0.0, threshold - (1.0 - alpha_amount));

	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALPHA = color.a * dither;
	ALBEDO = color.rgb;
}
