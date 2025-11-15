shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amplitude = 0.01;
uniform float wave_frequency = 10.0;
uniform float uv_left = 0.0;
uniform float uv_right = 1.0;
uniform float uv_top = 0.0;
uniform float uv_bottom = 1.0;
uniform float alpha = 1.0;

void vertex() {
    VERTEX = VERTEX * vec2(2.0);
}

void fragment() {
    vec2 uv = (UV - vec2(0.25)) * vec2(2.0);
    COLOR = texture(TEXTURE, uv);
    uv.x += 0.5 - (uv_left + uv_right) / 2.0;
    uv.y += 0.5 - (uv_top + uv_bottom) / 2.0;
    float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    uv.x += wave;
    if (uv.x < uv_left || uv.x > uv_right || uv.y < uv_top || uv.y > uv_bottom) {
        discard;
    } else {
        vec4 color = texture(TEXTURE, uv);
        color.a *= 0.25 * alpha;
        COLOR = color;
    }
}