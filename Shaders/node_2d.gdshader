
shader_type canvas_item;

//uniform vec4 my_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float MinValue: hint_range(0,1)=0.5;
uniform float MaxValue: hint_range(0,1)=0.5;
float Interpolate(float scaleValue,float minValue,float maxValue){
	if(scaleValue<minValue){
		return 0.0;
	}
	else if(scaleValue>maxValue){
		return 1.0;
	}
	else{
		return (scaleValue-minValue)/(maxValue-minValue);
	}
}
//uniform float scale: hint_range(0.0, 10)=1.0;
//uniform sampler2D gradient;
void vertex() {
	// Called for every vertex the material is visible on.
}







void fragment() {
	
	//vec2 distordedUV=UV;
	//distordedUV.x += distordedUV.y*1.0;
	//vec4 filter = mix(pixelColor,gradientColor,flashState);
	float flashState;
	float AmpUV=sqrt(pow(abs(UV.x-0.5),2)+pow(abs(UV.y-0.5)*757.0/563.0,2));
	vec4 pixelColor = texture(TEXTURE,UV);
	float brightness = (pixelColor.r+pixelColor.g+pixelColor.b)/3.0;
	vec4 grayScale = vec4(brightness,brightness,brightness,pixelColor.a);
	vec4 gradientColor;
	if(MinValue<MaxValue){
		flashState=Interpolate(AmpUV,MinValue,MaxValue);
		gradientColor = mix(grayScale,pixelColor,flashState);
	}
	else{
		flashState=Interpolate(AmpUV,MaxValue,MinValue);
		gradientColor = mix(pixelColor,grayScale,flashState);
	}
	
	
	
	//vec4 gradientColor=texture(gradient,UV);
	
	
	COLOR=gradientColor;
	//if(sqrt(pow(UV.x-0.5,2)+pow((UV.y-0.5)*757.0/563.0,2))>0.5){
	//COLOR.rgb=vec3(COLOR.r,brightness,COLOR.b);
	//}
	//else{
		//COLOR.rgb=vec3(brightness,COLOR.g,brightness);
	//}
	
	//if(UV.x>0.5 && UV.y>0.5){
		//COLOR.rgb=vec3(brightness,brightness,brightness);
	//}
	
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
