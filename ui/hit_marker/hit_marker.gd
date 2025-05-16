class_name UIHitMarker
extends DrawMarker

@export var SHOW_TIME: float = 0.15

var _timer: float = 0.0
var _visible: bool = false
var _fade: float = 1.0
var _rotation: float = 0.0

func _ready() -> void:
	super._ready()
	randomize()
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	visible = false

func show_hit_marker(screen_position: Vector2) -> void:
	_timer = SHOW_TIME
	_fade = 1.0
	_visible = true
	visible = true
	_rotation = randf_range(0.0, TAU)
	rotation = _rotation
	position = screen_position - size * 0.5
	queue_redraw()

func _process(delta: float) -> void:
	if _visible:
		_timer -= delta
		if _timer <= 0.0:
			_fade = max(_fade - delta * 8.0, 0.0)
			if _fade <= 0.0:
				_visible = false
				visible = false
		queue_redraw()
