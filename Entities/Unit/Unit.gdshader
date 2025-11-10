shader_type canvas_item;

uniform float hide_pixels = 0.0;

void fragment() {
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));
    float cutoff = (texture_size.y - hide_pixels) / texture_size.y;

    if (UV.y > cutoff) {
        discard;
    }
    COLOR = texture(TEXTURE, UV);
}