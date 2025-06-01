// Modified version of this shader: https://godotshaders.com/shader/vignette-2/
// Credits for original shader go to original creator.
shader_type canvas_item;

uniform float alpha = 1.8;
uniform float inner_radius = 0.2; // prev: 0.3
uniform float outer_radius = 1.0; // prev: 2.5
uniform vec4 color : source_color = vec4(1, 0, 0, 1);

void fragment() {
	float x = abs(UV.r-.5)*2.0;
	float y = abs(UV.g-.5)*2.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);
	COLOR = vec4(color.rgb, q*alpha*color.a);
}
