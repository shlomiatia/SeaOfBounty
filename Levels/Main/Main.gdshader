shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float x_offset: hint_range(-0.5, 5.0, 0.001);
uniform float deg: hint_range(0.0, 1000.0, 0.1);
uniform float speed: hint_range(0.0, 500.0, 0.5);
uniform float amount: hint_range(0.0, 0.5, 0.01);
uniform float freq: hint_range(0.0, 1000.0, 0.5);
uniform sampler2D noise: repeat_enable;
uniform float x_amount: hint_range(0.0, 1.0, 0.1);
uniform float y_amount: hint_range(0.0, 1.0, 0.1);
uniform vec4 tint: source_color;
uniform vec2 scale;
uniform vec2 zoom;

void fragment() {
    float white_value = texture(noise, UV*scale*0.5 + vec2(TIME*speed/200.0, 0.0)).r;
    float offset = white_value * amount - amount / 2.0;
    vec2 offset_vector = vec2(offset * x_amount, offset * y_amount);
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + offset_vector * zoom.y);
    COLOR = mix(COLOR, tint, 0.5);
}