shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D albedo_texture;
uniform sampler2D noise_texture;
uniform float paper_wrinkles : hint_range(0, 1) = 0.3;
uniform float paper_yellowing : hint_range(0, 1) = 0.2;
uniform float edge_wear : hint_range(0, 1) = 0.15;

uniform vec4 paper_color: source_color = vec4(0.95, 0.93, 0.85, 1.0);
uniform vec4 edge_dirt_color: source_color = vec4(0.7, 0.65, 0.6, 1.0);

void fragment() {
	// Get UV coordinates with slight distortion for paper texture
	vec2 distorted_uv = UV;

	// Add subtle paper-like distortion using noise texture
	// Ensure noise is in a good range for distortion (e.g., -1 to 1)
	float noise = texture(noise_texture, UV * 2.0).r * 2.0 - 1.0;
	distorted_uv += noise * 0.005 * paper_wrinkles; // Small distortion for subtle effect

	// Sample the original texture using the distorted UVs
	vec4 tex_color = texture(albedo_texture, distorted_uv);

	// Add slight yellowing/browning of paper
	tex_color.rgb = mix(tex_color.rgb,
						paper_color.rgb,
						paper_yellowing * 0.5
					);

	// Edge wear effect
	// Calculate distance from the center to create edge effect
	float edge_factor = max(abs(UV.x - 0.5) * 2.0, abs(UV.y - 0.5) * 2.0);
	edge_factor = pow(edge_factor, 15.0); // Power to make the falloff sharper
	tex_color.rgb = mix(tex_color.rgb,
						edge_dirt_color.rgb,
						edge_factor * edge_wear
					);

	ALBEDO = tex_color.rgb;

	// Make it more matte
	ROUGHNESS = 1.0;
	METALLIC = 0.0;

	float h_right = texture(noise_texture, UV + vec2(0.001, 0.0) * 10.0).r;
	float h_up = texture(noise_texture, UV + vec2(0.0, 0.001) * 10.0).r;

	// Calculate derivatives
	vec3 tangent_x = vec3(1.0, 0.0, (h_right - noise));
	vec3 tangent_y = vec3(0.0, 1.0, (h_up - noise));

	// Cross product to get the new normal in tangent space
	NORMAL = normalize(cross(tangent_x, tangent_y));
	float normal_noise_val = texture(noise_texture, UV * 100.0).r;
	NORMAL = normalize(vec3(
	    (texture(noise_texture, UV * 10.0 + vec2(0.01, 0.0)).r - normal_noise_val) * paper_wrinkles,
	    (texture(noise_texture, UV * 10.0 + vec2(0.0, 0.01)).r - normal_noise_val) * paper_wrinkles,
	    0.8 // Z-component pointing out
	));
}