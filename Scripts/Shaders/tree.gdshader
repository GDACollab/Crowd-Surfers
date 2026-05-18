shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : filter_nearest, source_color;
uniform vec3 scale = vec3(1,1,1);
uniform float wind_strength : hint_range(0.1, 1.0, 0.02);
uniform float wind_speed : hint_range(0.5, 2.0, 0.1);

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * wind_speed + UV.y) * ( 1.0 - UV.y) * wind_strength;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * wind_speed + UV.y) * ( 1.0 - UV.y) * wind_strength;
	VERTEX = VERTEX * vec3(scale.x, scale.y, scale.z);
}

void fragment(){
	ALBEDO = texture(albedo_texture, UV).rgb;
	ALPHA = texture(albedo_texture, UV).a;
}