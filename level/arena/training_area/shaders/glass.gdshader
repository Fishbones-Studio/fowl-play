// based on https://godotshaders.com/shader/frosted-glass-3/
shader_type spatial;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D frosted_texture : source_color, repeat_enable;

uniform int lod_level : hint_range(0, 10) = 4;
uniform float brightness : hint_range(0.0, 100.0) = 1.0;
uniform float distortion_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float transparency : hint_range(0.0, 1.0) = 0.7; // Higher = more see-through

float w0(float a) {
	return (1.0f / 6.0f) * (a * (a * (-a + 3.0f) - 3.0f) + 1.0f);
}

float w1(float a) {
	return (1.0f / 6.0f) * (a * a * (3.0f * a - 6.0f) + 4.0f);
}

float w2(float a) {
	return (1.0f / 6.0f) * (a * (a * (-3.0f * a + 3.0f) + 3.0f) + 1.0f);
}

float w3(float a) {
	return (1.0f / 6.0f) * (a * a * a);
}

float g0(float a) {
	return w0(a) + w1(a);
}

float g1(float a) {
	return w2(a) + w3(a);
}

float h0(float a) {
	return -1.0f + w1(a) / (w0(a) + w1(a));
}

float h1(float a) {
	return 1.0f + w3(a) / (w2(a) + w3(a));
}

vec4 texture2D_bicubic(sampler2D tex, vec2 uv, int p_lod, ivec2 tex_size) {
	vec2 tex_size_lod = vec2(tex_size >> p_lod);
	vec2 pixel_size = vec2(1.0f) / tex_size_lod;
	uv = uv * tex_size_lod + vec2(0.5f);
	vec2 iuv = floor(uv);
	vec2 fuv = fract(uv);
	float g0x = g0(fuv.x);
	float g1x = g1(fuv.x);
	float h0x = h0(fuv.x);
	float h1x = h1(fuv.x);
	float h0y = h0(fuv.y);
	float h1y = h1(fuv.y);
	vec2 p0 = (vec2(iuv.x + h0x, iuv.y + h0y) - vec2(0.5f)) * pixel_size;
	vec2 p1 = (vec2(iuv.x + h1x, iuv.y + h0y) - vec2(0.5f)) * pixel_size;
	vec2 p2 = (vec2(iuv.x + h0x, iuv.y + h1y) - vec2(0.5f)) * pixel_size;
	vec2 p3 = (vec2(iuv.x + h1x, iuv.y + h1y) - vec2(0.5f)) * pixel_size;
	return (g0(fuv.y) * (g0x * textureLod(tex, p0, float(p_lod)) + g1x * textureLod(tex, p1, float(p_lod)))) +
		   (g1(fuv.y) * (g0x * textureLod(tex, p2, float(p_lod)) + g1x * textureLod(tex, p3, float(p_lod))));
}

void fragment() {
	vec2 screen_uv = SCREEN_UV;

	vec2 distortion = texture(frosted_texture, UV).rg - 0.5;
	distortion = normalize(distortion) * distortion_intensity;

	vec2 distorted_uv = screen_uv + distortion;

	vec4 blurred_color = texture2D_bicubic(screen_texture, distorted_uv, lod_level, textureSize(screen_texture, 0));

	vec3 adjusted_color = blurred_color.rgb * brightness;

	ALBEDO = adjusted_color;
	ALPHA = transparency;
}
