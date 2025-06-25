class_name CustomButton
extends Button

@export_group("Transitions")
@export var transition_scale_up: float = 1.05
@export var transition_scale_down: float = 0.95
@export var transition_time: float = 0.05

var _default_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	pivot_offset = size / 2
	_default_scale = scale

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	button_up.connect(_on_button_up)
	button_down.connect(_on_button_down)


func _on_focus_entered() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(transition_scale_up, transition_scale_up), transition_time)


func _on_focus_exited() -> void:
	TweenManager.create_scale_tween(null, self, _default_scale, transition_time)


func _on_button_up() -> void:
	if not has_focus():
		TweenManager.create_scale_tween(null, self, _default_scale, transition_time)
	else:
		_on_focus_entered()


func _on_button_down() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(transition_scale_down, transition_scale_down), transition_time)
