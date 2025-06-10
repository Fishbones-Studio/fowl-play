shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

instance uniform vec4 main_color : source_color = vec4(0.7, 0.02, 0.01, 1.0);
uniform sampler2D noise_texture;
uniform float splatter_scale = 1.0;
uniform float distortion_amount : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float edge_variation : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float noise_contrast : hint_range(1.0, 10.0, 0.1) = 1.0;

void vertex() {
	COLOR = vec4(float(INSTANCE_ID), INSTANCE_CUSTOM.y, 0.0, 0.0);
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv_dir = (UV - center) / splatter_scale;
	float radius = length(uv_dir) * 2.0;

	float gradient = 1.0 - radius;
	float distortion_strength = COLOR.r * distortion_amount;
	vec2 distorted_uv = UV + vec2(distortion_strength) / splatter_scale;

	float noise_value = pow(texture(noise_texture, distorted_uv).r, noise_contrast);
	float mask = gradient * noise_value;
	float edge_fade = 1.0 - COLOR.g * edge_variation;

	ALBEDO = main_color.rgb * vec3(mask);
	ALPHA = edge_fade * mask;
	ALPHA_SCISSOR_THRESHOLD = 1.0 - mask;
}