shader_type spatial;

uniform sampler2D texture_array[2];

uniform float timeOffset = 0;
uniform float secondsPerFrame = 0.3f;

void fragment() {
	// Called for every pixel the material is visible on.
	float time = TIME + timeOffset;
	int frame = (int(floor(time / secondsPerFrame))) % texture_array.length();
	
	vec4 textureFrame = texture(texture_array[frame], UV);
	ALBEDO = textureFrame.rgb;
	ALPHA = textureFrame.a;
}
