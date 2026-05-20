shader_type spatial;

uniform sampler2DArray texture_array[16] : filter_nearest, source_color;
const int animationCount = 8;
const int frameCount = 2;

uniform float timeOffset = 0;
uniform float secondsPerFrame = 0.3f;
uniform float alpha_scissor_threshold = 0.2;

varying vec4 customInfo;

void fragment() {
	// Called for every pixel the material is visible on.
	float time = TIME + timeOffset;
	int frame = (int(floor((customInfo.x + time) / secondsPerFrame))) % frameCount;
	// Finds the depth of the layer
	//int layer = (int(floor((customInfo.y + time) * 4.0)));
	//int layer = frame + (int(floor((customInfo.y + time) * 4.0)));
	int frame_index = int(floor(customInfo.y * float(animationCount)));
	// customInfo is frame index, frame count is sprite sheet size, and the frame is itself or which it should have
	//int layer = frame + int(floor(customInfo.x * float(frameCount)));
	int layer = frame + (frame_index * frameCount);

	//vec4 textureFrame = texture(texture_array[frame + (2 * int(floor(customInfo.y * 4.0f)))], UV);
	//COLOR = texture(texture_array, vec3(UV, frame));
	vec4 textureFrame = texture(texture_array[layer], vec3(UV, float(layer)));
	//vec4 textureFrame = texture(texture_array[layer], UV);
	ALBEDO = textureFrame.rgb;
	ALPHA = textureFrame.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;

}

void vertex(){
	//I'm not cheating mom, it's called "varying", ugh!
	//seriously this is the actual way the explain how to do this in the documentation. lmao
	customInfo = INSTANCE_CUSTOM;
}