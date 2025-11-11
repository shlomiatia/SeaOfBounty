shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amplitude = 0.01;
uniform float wave_frequency = 10.0;

void fragment() {
    vec2 uv = UV;
    
    float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    uv.x += wave;
    uv.x = clamp(uv.x, 0.0, 1.0);
    uv.y = clamp(uv.y, 0.0, 1.0);
    
    vec4 color = texture(TEXTURE, uv);
    color.a *= 0.25;
    
    COLOR = color;
}