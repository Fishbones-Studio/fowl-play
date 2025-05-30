extends CenterContainer

@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.WHITE


func _ready() -> void:
	queue_redraw()

# function to draw dot
func _draw() -> void:
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR)
