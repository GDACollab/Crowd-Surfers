shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color;

void fragment() {
    if ((int(FRAGCOORD.x) + int(FRAGCOORD.y)) % 2 == 0) discard;
    vec4 tex = texture(albedo_texture, UV);
    if (tex.a < 0.5) discard;
    ALBEDO = tex.rgb;
}