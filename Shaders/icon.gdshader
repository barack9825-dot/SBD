shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture, filter_linear_mipmap;
uniform sampler2D curve;
//uniform sampler2D distortionTexture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 vecToCenter=vec2(0.5,0.5)-UV;
	float distToCenter = length(vecToCenter);
	float curveVal=texture(curve,vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter)*0.6*curveVal;
	//vec2 distordedUV=SCREEN_UV+texture(distortionTexture,UV).r*0.1;
	//vec4 screenColor=texture(SCREEN_TEXTURE,distordedUV);
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV-diff);
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
