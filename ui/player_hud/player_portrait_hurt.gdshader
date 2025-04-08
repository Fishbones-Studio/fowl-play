shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable;
uniform vec3 hurt_color = vec3(0.8, 0.0, 0.0);
uniform float overlay_alpha : hint_range(0.0, 1.0) = 0.5;
uniform float aberration_strength : hint_range(0.0, 2.0) = 0.8;
uniform float displacement_strength : hint_range(0.0, 50.0) = 15.0;
uniform float time;

void fragment() {
    vec2 uv = SCREEN_UV;

    uv += vec2(
        sin(uv.y + time),
        cos(uv.x + time)
    ) * displacement_strength;

    // Chromatic aberration offsets
    vec2 offset = (uv - vec2(0.5)) * aberration_strength;

    float r = texture(screen_texture, uv + offset).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - offset).b;

    vec3 aberrated_color = vec3(r, g, b);

    // Compute difference between channels, for the mixing
    float diff = abs(r - b);

    // Blend factor, to blend between the hurt color and chromatic abberation
    float blend_factor = clamp(1.0 - diff * 10.0, 0.0, 1.0);
    vec3 final_color = mix(aberrated_color, hurt_color, blend_factor);

    COLOR = vec4(final_color, overlay_alpha);
}
