shader_type spatial;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
//uniform sampler2D SCREEN_LIGHT: hint_default_transparent;
uniform float valueMax:hint_range(0,1)=0.5;
uniform float valueMin:hint_range(0,1)=0.5;
uniform vec3 camera_pos; 
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE,SCREEN_UV);
	ALBEDO =screen_color.rgb;
	//ALPHA=0.5;
	//ROUGHNESS=value;
	

	// Called for every pixel the material is visible on.
}

void light() {
	
	//DIFFUSE_LIGHT = LIGHT_COLOR*min(dot(NORMAL,LIGHT),0.0);
	// Called for every pixel for every light affecting the material.
}
