shader_type canvas_item;

uniform float skew_x : hint_range(-2.0, 2.0) = -1.0;

void vertex() {
    VERTEX.x += VERTEX.y * skew_x;
}

