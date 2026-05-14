shader_type spatial;

uniform sampler2D texture_array[8];
const int animationCount = 4;
const int frameCount = 2;

uniform float timeOffset = 0;
uniform float secondsPerFrame = 0.3f;

varying vec4 customInfo;

void fragment() {
	// Called for every pixel the material is visible on.
	float time = TIME + timeOffset;
	int frame = (int(floor((customInfo.x + time) / secondsPerFrame))) % frameCount;
	
	vec4 textureFrame = texture(texture_array[frame + (2 * int(floor(customInfo.y * 4.0f)))], UV);
	ALBEDO = textureFrame.rgb;
	ALPHA = textureFrame.a;
}

void vertex(){
	//I'm not cheating mom, it's called "varying", ugh!
	//seriously this is the actual way the explain how to do this in the documentation. lmao
	customInfo = INSTANCE_CUSTOM;
}