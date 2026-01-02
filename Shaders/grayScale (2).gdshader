shader_type spatial;

global uniform vec3 player_pos : hint_range(-100,100);
uniform float sphere_size : hint_range(0.1, 20.0) = 3.0;
uniform sampler2D my_texture;
uniform float value : hint_range(-1,10) = 0.5;

void fragment() {
    vec4 pixelColor = textureLod(my_texture, UV, 0.0);
    
    // RECONSTRUCCIÓN CORRECTA de World Position en fragment (Godot 4.2)
    vec3 world_position = (INV_VIEW_MATRIX * vec4(VIEW_POSITION, 1.0)).xyz;
    
    float dist = length(player_pos - world_position);
    float flashState = clamp(sphere_size - dist, 0.0, 1.0);
    
    float brightness = dot(pixelColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayScale = vec3(brightness);
    
    ALBEDO = mix(pixelColor.rgb, grayScale, flashState);
    ALPHA = pixelColor.a * flashState;
}
