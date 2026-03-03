shader_type canvas_item;

uniform vec4 clr : source_color = vec4(0.1,1.0,1.0,1.0);
uniform int dist : hint_range(1, 10, 1) = 1;

float avg_alpha(sampler2D tex, vec2 coords, vec2 pixelSize){
  float result = 0.0;
  for (int i = -dist; i<=dist; i++){
    for (int j = -dist; j<=dist; j++){
      result += texture(tex, coords + vec2(float(i),float(j))*pixelSize).a;
    }
  };
  return result;
} 

void fragment() {
  if (COLOR.a<1.0){
    COLOR.rgb = mix(clr.rgb,COLOR.rgb,COLOR.a);
    COLOR.a = mix(avg_alpha(TEXTURE,UV,TEXTURE_PIXEL_SIZE),COLOR.a,COLOR.a);
  }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}