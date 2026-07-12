shader_type spatial;
//#include "res://Shaders/include_1.gdshaderinc"


global uniform vec3 player_pos;
global uniform vec3 player_pos2;
global uniform vec3 player_selected;
global uniform bool purifying;
global uniform float purifying_progress;
varying vec3 world_vertex;
uniform sampler2D my_texture;


void vertex() {
	world_vertex=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float sphere_size;
	vec4 pixelColor            = textureLod(my_texture,UV,0.0);
	//vec4 pixelColor = vec4(0,0,0,0);

	float player_dist_selected = min(length(world_vertex-player_pos),length(world_vertex-player_pos2));
	float player_dist_no_selected = max(length(world_vertex-player_pos),length(world_vertex-player_pos2));
	float dist_min = length(world_vertex-player_selected)-player_dist_selected;
	
	if ( dist_min < 0.01 && player_dist_no_selected > 3.0)
	{
		sphere_size = 3.0 * (1.0 - purifying_progress); 

//	float player_dist_selected = min(length(player_pos-world_vertex),length(player_pos2-world_vertex));
	
//	if (purifying && player_dist_selected == length(player_selected-world_vertex))
//	{
//		sphere_size = 3.0 * (1.0 - purifying_progress);

	}
	else
	{
		sphere_size = 3.0;
	}
	
	float min_dist             = min(player_dist_selected,sphere_size);
	float flashState = clamp(sphere_size-min_dist,0.0,1.0);
	float brightness = (pixelColor.r+pixelColor.g+pixelColor.b)/3.0;
	vec4 grayScale   = vec4(brightness,brightness,brightness,pixelColor.a);
	
	ALBEDO=grayScale.rgb;
	//ALBEDO = vec3(0,0,0);

	if(pixelColor.a==0.0){
		ALPHA=0.0;
	}
	else{
		ALPHA=flashState;
	}
	
	// Called for every pixel the material is visible on.
}

void light() {
	DIFFUSE_LIGHT += LIGHT_COLOR*ATTENUATION * dot(LIGHT,NORMAL);
	//DIFFUSE_LIGHT += LIGHT_COLOR * dot(LIGHT,NORMAL);
	// Called for every pixel for every light affecting the material.
}
