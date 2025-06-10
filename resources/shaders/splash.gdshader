shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

instance uniform vec4 main_color : source_color = vec4(0.7, 0.02, 0.01, 1.0);
uniform sampler2D noise_texture;
uniform float distortion_strength : hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float noise_power : hint_range(1.0, 10.0, 0.1) = 5.0;
uniform float base_alpha : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float angle_influence : hint_range(0.0, 1.0, 0.01) = 0.5;

void vertex() {
	mat4 billboard_matrix = VIEW_MATRIX * mat4(
	    INV_VIEW_MATRIX[0],
	    INV_VIEW_MATRIX[1],
	    INV_VIEW_MATRIX[2],
	    MODEL_MATRIX[3]
	);

	billboard_matrix *= mat4(
	    vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
	    vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
	    vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
	    vec4(0.0, 0.0, 0.0, 1.0)
	);

	MODELVIEW_MATRIX = billboard_matrix;
	COLOR.rgb = vec3(float(INSTANCE_ID), 0.0, 0.0);
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 dir = UV - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) / (PI * 2.0);

	float gradient = 1.0 - max(radius, angle * angle_influence);
	float distortion_factor = COLOR.r * distortion_strength;
	vec2 distorted_uv = UV + vec2(distortion_factor);
	float texture_value = pow(texture(noise_texture, distorted_uv).r, noise_power);

	vec3 final_color = main_color.rgb * (vec3(gradient) * vec3(texture_value));
	float alpha_threshold = 1.0 - (gradient * texture_value);

	ALBEDO = final_color;
	ALPHA = base_alpha;
	ALPHA_SCISSOR_THRESHOLD = alpha_threshold;
}