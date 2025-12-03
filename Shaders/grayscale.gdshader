shader_type spatial;
global uniform vec3 player_pos;
uniform float sphere_size=3.0;
varying vec3 world_vertex;
uniform sampler2D my_texture;
uniform float value:hint_range(-1,10)=0.5;

void vertex() {
	world_vertex=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixelColor=textureLod(my_texture,UV,0.0);
	float min_dist =min(length(player_pos-world_vertex),sphere_size);
	float flashState=clamp(sphere_size-min_dist,0.0,1.0);
	float brightness = (pixelColor.r+pixelColor.g+pixelColor.b)/3.0;
	vec4 grayScale = vec4(brightness,brightness,brightness,pixelColor.a);
	//ALBEDO=mix(pixelColor.rgb,grayScale.rgb,flashState);
	//ALPHA=pixelColor.a;
	
	
	ALBEDO=grayScale.rgb;
	if(pixelColor.a==0.0){
		ALPHA=0.0;
	}
	else{
		ALPHA=flashState;
	}
	
	// Called for every pixel the material is visible on.
}

void light() {
	//DIFFUSE_LIGHT=vec3(0.1);
	//DIFFUSE_LIGHT=LIGHT_COLOR*dot(LIGHT,NORMAL);
	// Called for every pixel for every light affecting the material.
}
