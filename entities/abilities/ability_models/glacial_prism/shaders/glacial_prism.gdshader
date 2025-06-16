// Credit to original shader: https://godotshaders.com/shader/spatial-ice-shader/
shader_type spatial;
render_mode depth_prepass_alpha, specular_schlick_ggx, unshaded;

uniform float FresnelPower = 2.5;
uniform vec4 FresnelColor : source_color;
uniform vec4 Color : source_color;
uniform vec3 Tiling = vec3(1.0, 1.0, 0.0);
uniform vec3 Offset = vec3(0.0, 0.0, 0.0);
uniform sampler2D Ice_Texture;
uniform float RefractionAmount = 1.0;
uniform float Metallic = 0.15;
uniform float Smoothness = 0.6;
uniform float Normals = 0.7;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Custom tiling and offset function
vec2 apply_tiling_offset(vec2 uv, vec2 offset) {
	return mod(uv + offset, 1.0);
}

// Reads and reconstructs normal from a normal map
vec3 get_normal_map(vec3 normalmap, vec3 base_normal, vec3 tangent, vec3 binormal, float depth) {
	normalmap.xy = normalmap.xy * 2.0 - 1.0;
	normalmap.z = sqrt(max(0.0, 1.0 - dot(normalmap.xy, normalmap.xy)));
	return normalize(mix(base_normal, tangent * normalmap.x + binormal * normalmap.y + base_normal * normalmap.z, depth));
}

void fragment() {
	// Fresnel effect
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), FresnelPower);
	vec3 fresnelColor = fresnel * FresnelColor.rgb;

	// Texture sampling with tiling and offset
	vec2 uv_tiled = apply_tiling_offset(UV * Tiling.xy, Offset.xy);
	vec4 tex_color = texture(Ice_Texture, uv_tiled);
	vec3 normal_map = tex_color.rgb;

	// Refraction
	vec3 screen_uv = vec3(SCREEN_UV, 0.0);
	float distortion = dot(screen_uv, vec3(0.3333)) * normal_map.r;
	float distorted_luminance = dot(screen_uv, vec3(0.3333)) + distortion;
	vec3 refraction_offset = (screen_uv - vec3(distorted_luminance)) * RefractionAmount;
	vec3 screen_sample = texture(SCREEN_TEXTURE, (screen_uv + refraction_offset).xy).rgb;

	// Final base color mix
	vec3 base_color = Color.rgb * (tex_color.rgb + screen_sample);
	vec3 final_color = fresnelColor + base_color;

	// Final outputs
	ALBEDO = final_color;
	ALPHA = Color.a;
	METALLIC = Metallic;
	SPECULAR = Smoothness;
	NORMAL = get_normal_map(normal_map, NORMAL, TANGENT, BINORMAL, Normals);
}
