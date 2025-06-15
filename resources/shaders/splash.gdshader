shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

instance uniform vec4 main_color : source_color = vec4(0.7, 0.02, 0.01, 1.0);
uniform sampler2D noise_texture;
uniform float distortion_amount : hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float noise_power : hint_range(-5.0, 10.0, 0.1) = 5.0;
uniform float base_alpha : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float angle_influence : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float gradient_strength : hint_range(0.0, 10.0, 0.1)= 2.0;

void vertex() {
	mat4 billboard_matrix = VIEW_MATRIX;
	billboard_matrix[0] = VIEW_MATRIX * INV_VIEW_MATRIX[0];
	billboard_matrix[1] = VIEW_MATRIX * INV_VIEW_MATRIX[1];
	billboard_matrix[2] = VIEW_MATRIX * INV_VIEW_MATRIX[2];
	billboard_matrix[3] = VIEW_MATRIX * MODEL_MATRIX[3];

	billboard_matrix[0][0] = length(MODEL_MATRIX[0].xyz);
	billboard_matrix[1][1] = length(MODEL_MATRIX[1].xyz);
	billboard_matrix[2][2] = length(MODEL_MATRIX[2].xyz);

	MODELVIEW_MATRIX = billboard_matrix;
	COLOR.r = float(INSTANCE_ID);
	COLOR.g = 0.0;
	COLOR.b = 0.0;
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 dir = UV - center;
	float radius = length(dir) * gradient_strength;
	float angle = atan(dir.y, dir.x) / (PI * 2.0);
	float gradient = 1.0 - max(radius, angle * angle_influence);

	float distortion_strength = COLOR.r * distortion_amount;
	vec2 distorted_uv = UV + vec2(distortion_strength);
	float texture_value = pow(texture(noise_texture, distorted_uv).r, noise_power);

	vec3 final_color = main_color.rgb * (vec3(gradient) * vec3(texture_value));
	float alpha_threshold = 1.0 - (gradient * texture_value);

	ALBEDO = final_color;
	ALPHA = base_alpha;
	ALPHA_SCISSOR_THRESHOLD = alpha_threshold;
}