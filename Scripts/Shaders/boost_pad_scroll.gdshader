shader_type spatial;
render_mode depth_draw_opaque, depth_prepass_alpha, unshaded;

uniform sampler2D texture_albedo : source_color;
uniform vec2 scroll_speed = vec2(0.1, 0.0);
uniform vec3 emission_color : source_color;
uniform float emission_energy;

void fragment() {
	vec2 base_uv = UV - (scroll_speed * TIME);
	ALBEDO = texture(texture_albedo, base_uv).rgb;
	EMISSION = emission_color * emission_energy;
}