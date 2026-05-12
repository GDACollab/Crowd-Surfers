shader_type spatial;

uniform sampler2D texture_array[2];

uniform float timeOffset = 0;
uniform float secondsPerFrame = 0.3f;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float time = TIME + timeOffset;
	int frame = (int(floor(time / secondsPerFrame))) % texture_array.length();
	
	ALBEDO = texture(texture_array[frame], UV);
}
