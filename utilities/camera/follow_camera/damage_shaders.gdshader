shader_type canvas_item;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float intensity = 0.0;

void fragment() {
	vec2 uv = (FRAGCOORD.xy / SCREEN_PIXEL_SIZE) / SCREEN_PIXEL_SIZE - 0.5;
	COLOR = vec4(uv.x + 0.5, uv.y + 0.5, 0.0, 1.0); // Visualize uv
}

