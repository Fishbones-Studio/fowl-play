shader_type spatial;

uniform sampler2D noise_texture : source_color, filter_linear_mipmap, repeat_enable;

// Colors
uniform vec4 hot_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 mid_color : source_color = vec4(0.7, 0.2, 0.0, 1.0);
uniform vec4 cool_color : source_color = vec4(0.2, 0.05, 0.0, 1.0);

// Animation Noise
uniform float master_time_scale = 1.0;
uniform float noise_scale_primary = 2.5;
uniform float noise_scale_secondary = 5.0;
uniform float flow_speed_primary = 0.06;
uniform float flow_speed_secondary = 0.035;

// Surface Distortion
uniform float distortion_scale = 4.0;
uniform float distortion_speed = 0.04;
uniform float distortion_strength = 0.02;

// Emission
uniform float emission_boost = 4.0;

// Color Transition Thresholds
uniform float cool_thresh = 0.35;
uniform float mid_thresh = 0.60;

// Bubbling (vertex displacement)
uniform float bubble_strength = 0.1; // How much the surface "bubbles"
uniform float bubble_scale = 4.0;     // Scale of the bubbling pattern
uniform float bubble_speed = 0.3;     // Speed of bubbling

void vertex() {
    float t = TIME * master_time_scale * bubble_speed;
    // Use UV for 2D noise
    vec2 bubble_uv = UV * bubble_scale + vec2(t, -t * 0.5);
    float bubble = texture(noise_texture, bubble_uv).r;
    // Center and shape the bubble effect
    bubble = (bubble - 0.5) * 2.0;
    // Animate with a little sine for extra "popping"
    bubble *= 0.7 + 0.3 * sin(TIME * 2.0 + VERTEX.x * 3.0 + VERTEX.y * 2.0);
    // Displace along normal
    VERTEX += NORMAL * bubble * bubble_strength;
}

void fragment() {
    float current_time = TIME * master_time_scale;

    // Create two differently scrolling UVs for sampling distortion noise
    vec2 dist_uv_scroll_base = UV * distortion_scale;
    vec2 dist_uv1 = dist_uv_scroll_base +
                    vec2(current_time * distortion_speed,
                         current_time * distortion_speed * 0.7);
    vec2 dist_uv2 = dist_uv_scroll_base +
                    vec2(-current_time * distortion_speed * 0.5,
                         current_time * distortion_speed * 1.2);

    float d_x = texture(noise_texture, dist_uv1).r;
    float d_y = texture(noise_texture, dist_uv2).r;

    vec2 uv_offset_for_distortion = vec2(d_x - 0.5, d_y - 0.5) * distortion_strength;
    vec2 distorted_base_uv = UV + uv_offset_for_distortion;

    vec2 uv_flow1 = distorted_base_uv * noise_scale_primary;
    uv_flow1.x += current_time * flow_speed_primary;
    uv_flow1.y += current_time * flow_speed_primary * 0.6;
    float noise_val1 = texture(noise_texture, uv_flow1).r;

    vec2 uv_flow2 = distorted_base_uv * noise_scale_secondary;
    uv_flow2.x -= current_time * flow_speed_secondary * 0.7;
    uv_flow2.y += current_time * flow_speed_secondary;
    float noise_val2 = texture(noise_texture, uv_flow2).r;

    float combined_noise = (noise_val1 + noise_val2) * 0.5;

    vec3 final_albedo_color;
    float t_cool_to_mid = smoothstep(cool_thresh - 0.05, cool_thresh + 0.05, combined_noise);
    final_albedo_color = mix(cool_color.rgb, mid_color.rgb, t_cool_to_mid);

    float t_mid_to_hot = smoothstep(mid_thresh - 0.05, mid_thresh + 0.05, combined_noise);
    final_albedo_color = mix(final_albedo_color, hot_color.rgb, t_mid_to_hot);

    ALBEDO = final_albedo_color;

    float hotness_for_emission = smoothstep(cool_thresh, mid_thresh + 0.1, combined_noise);
    EMISSION = final_albedo_color * pow(hotness_for_emission, 2.0) * emission_boost;
}
