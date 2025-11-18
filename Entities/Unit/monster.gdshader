shader_type canvas_item;

uniform float hide_pixels = 0.0;
uniform vec4 modulate: source_color = vec4(1.0);
uniform vec4 water_color: source_color;
uniform float bottom;

bool colors_match(vec4 a, vec4 b) {
    return distance(a, b) < 0.1;
}

void fragment() {
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));
    float cutoff = bottom - hide_pixels / texture_size.y;

    vec4 current_color = texture(TEXTURE, UV) * modulate;

    vec2 source_uv = UV + vec2(0.0, hide_pixels / texture_size.y);
    vec4 src_color = texture(TEXTURE, source_uv) * modulate;

    if (colors_match(src_color, water_color)) {
        COLOR = water_color;
    }
    else if (!colors_match(current_color, water_color) && UV.y > cutoff && current_color.a > 0.0) {
        COLOR = vec4(water_color.rgb, 0.5);
    }
    else if (colors_match(current_color, water_color)) {
        discard;
    }
    else {
        COLOR = current_color;
    }
}
