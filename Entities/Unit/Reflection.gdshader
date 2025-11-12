shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amplitude = 0.01;
uniform float wave_frequency = 10.0;
uniform float uv_left = 0.0;
uniform float uv_right = 1.0;

void fragment() {
    vec2 uv = UV;

    float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    uv.x += wave;
    if (uv.x < uv_left || uv.x > uv_right) {
        discard;
    } else {
        vec4 color = texture(TEXTURE, uv);
        color.a *= 0.25;

        COLOR = color;
    }
}