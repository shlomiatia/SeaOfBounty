shader_type canvas_item;

uniform float hide_pixels = 0.0;
uniform vec4 modulate: source_color = vec4(1.0);
uniform vec4 water_color: source_color;

void fragment() {
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));
    float cutoff = (texture_size.y - hide_pixels) / texture_size.y;

    vec4 color = texture(TEXTURE, UV);
    if (UV.y > cutoff && color.a > 0.0) {
        color = water_color;
    }
    COLOR = color;
}