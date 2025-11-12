shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amplitude = 0.01;
uniform float wave_frequency = 10.0;

void fragment() {
    vec2 uv = UV;
    
    float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    uv.x += wave;
    if (uv.x < 84.0/165.0 || uv.x > 123.0/165.0) {
        discard;
    } else {
        vec4 color = texture(TEXTURE, uv);
        color.a *= 0.25;
        
        COLOR = color;    
    }
}