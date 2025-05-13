shader_type canvas_item;

// Screen texture and size
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
uniform vec2 screen_size = vec2(1920.0, 1080.0);

// Color and dithering controls
uniform int colors : hint_range(1, 16) = 12;
uniform int dither_size : hint_range(1, 8) = 1;
// Color shift for dithering
uniform float dither_shift : hint_range(-1.0, 1.0) = -1.0;
uniform float dither_strength : hint_range (-1.0, 1.0) = 0.5;

// Visual controls
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float scale : hint_range(1.0, 2.0) = 1.0;
uniform float border_mask : hint_range(0.0, 5.0) = 2.0;

// 4x4 Bayer matrix for dithering
float dithering_pattern(ivec2 fragcoord) {
    const float pattern[] = {
        0.00, 0.50, 0.10, 0.65,
        0.75, 0.25, 0.90, 0.35,
        0.20, 0.70, 0.05, 0.50,
        0.95, 0.40, 0.80, 0.30
    };
    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;
    return pattern[y * 4 + x] + dither_strength;
}

// Reduces a color channel to a limited palette, with dithering
float reduce_color(float raw, float dither, int depth) {
    float div = 1.0 / float(depth);
    float val = 0.0;
    int i = 0;
    while (i <= depth) {
        if (raw > div * float(i + 1)) {
            i = i + 1;
            continue;
        }
        if (raw * float(depth) - float(i) <= dither * 0.999) {
            val = div * float(i);
        } else {
            val = div * float(i + 1);
        }
        return val;
        i = i + 1;
    }
    return val;
}

void fragment() {
    // Normalized screen UV
    vec2 uv = FRAGCOORD.xy / screen_size;

    // Border mask and scaling
    float scale_reverse = 2.0 - scale;
    vec2 uvs = uv * scale_reverse + vec2(1.0 - scale_reverse) / 2.0;
    vec2 mask = pow(2.0 * abs(UV - 0.5), vec2(border_mask));

    // Sample color channels with border mask and scaling
    float r = texture(SCREEN_TEXTURE, uvs + vec2(SCREEN_PIXEL_SIZE) * mask, 0.0).r;
    float g = texture(SCREEN_TEXTURE, uvs + vec2(SCREEN_PIXEL_SIZE) * mask, 0.0).g;
    float b = texture(SCREEN_TEXTURE, uvs + vec2(SCREEN_PIXEL_SIZE) * mask, 0.0).b;
    vec4 raw = vec4(r, g, b, 1.0);

    // Dithering coordinates
    ivec2 dither_uv = ivec2(FRAGCOORD.xy / float(dither_size));
    float dithering_value = dithering_pattern(dither_uv);

    // Dithering values per channel (original formula + color shift)
    float dither_r = (dithering_value) * dithering_value + dither_shift;
    float dither_g = (dithering_value) * dithering_value - dither_shift;
    float dither_b = (dithering_value) * dithering_value;

    // Reduce color channels with dithering and color shift
    COLOR.r = reduce_color(raw.r, dither_r, colors - 1);
    COLOR.g = reduce_color(raw.g, dither_g, colors - 1);
    COLOR.b = reduce_color(raw.b, dither_b, colors - 1);
    COLOR.a = alpha;
}
