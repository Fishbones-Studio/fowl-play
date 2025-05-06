// Modifier shader based on: https://godotshaders.com/shader/corner-radius/
// All credit to original author.
shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 1.0) = 0.1;
uniform float border_width : hint_range(0.0, 0.1) = 0.02;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 size = vec2(textureSize(TEXTURE, 0));
    float radius = corner_radius * .5 * min(size.x, size.y);
    float border = border_width * min(size.x, size.y);

    vec2 pos = UV * size;

    vec2 from_center = vec2(0.0);

    if (pos.x < radius && pos.y < radius) {
        from_center = pos - vec2(radius, radius);
    } else if (pos.x > size.x - radius && pos.y < radius) {
        from_center = pos - vec2(size.x - radius, radius);
    } else if (pos.x < radius && pos.y > size.y - radius) {
        from_center = pos - vec2(radius, size.y - radius);
    } else if (pos.x > size.x - radius && pos.y > size.y - radius) {
        from_center = pos - vec2(size.x - radius, size.y - radius);
    }

    float dist = length(from_center);

    if (from_center != vec2(0.0) && dist > radius) {
        discard;
    }

    if (from_center != vec2(0.0) && dist > radius - border) {
        COLOR = border_color;
    } else if (
        (pos.x < border || pos.x > size.x - border) ||
        (pos.y < border || pos.y > size.y - border)
    ) {
        COLOR = border_color;
    } else {
        COLOR = texture(TEXTURE, UV);
    }
}
