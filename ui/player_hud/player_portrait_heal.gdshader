// Based on "Web Safe Darkened Gaussian Blur" by crisp_lad
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float blur_strength : hint_range(0.1, 5.0) = 2.3;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.8;
uniform vec3 heal_color : source_color = vec3(0.0, 1.0, 0.4);
uniform float overlay_alpha : hint_range(0.0, 1.0) = 0.5;

// Formula stolen from the internet
float gaussianDistribution(float x, float STD) {
    return exp(-(x*x)/(2.0*STD*STD))/(sqrt(2.0*PI)*STD);
}

vec4 gaussianGlow(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius) {
    vec4 blurredPixel = vec4(0.0);
    float total_weight = 0.0;

    // Increased radius multiplier for more pronounced blur
    int actualRadius = int(round(4.0 * blur_strength));

    for(int i = -actualRadius; i <= actualRadius; i++) {
        for(int j = -actualRadius; j <= actualRadius; j++) {
            vec2 offset = vec2(float(i), float(j)) * pixel_size;
            vec2 samplePos = pos + offset;

            // Calculate 2D Gaussian weight
            float weight = gaussianDistribution(float(i), sigmaUsed) *
                          gaussianDistribution(float(j), sigmaUsed);

            blurredPixel += texture(sampler, samplePos) * weight;
            total_weight += weight;
        }
    }

    blurredPixel /= total_weight;
    return blurredPixel;
}

void fragment() {
    // Get the blurred result
    vec4 blurred = gaussianGlow(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE, blur_strength, int(round(4.0 * blur_strength)));

    // Apply glow color and intensity
    vec3 glow = blurred.rgb * heal_color * glow_intensity;

    // Maintain alpha from original blur
    float alpha = max(blurred.a, overlay_alpha);

    COLOR = vec4(glow, alpha);
}
