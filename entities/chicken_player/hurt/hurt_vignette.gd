class_name HurtVignette
extends ColorRect

@export var thresholds: Array[float] = [1.8, 2.4, 3.0, 3.6]
@export var rise_duration: float = 0.5
@export var fall_duration: float = 3.0

var _current_threshold: int = -1
var _active_tween: Tween = null
var _current_animated_value: float = 0.0

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = fall_duration


func trigger() -> void:
	# Cancel any existing tweens
	if _active_tween:
		_active_tween.kill()

	if not timer.is_stopped():
		_current_threshold = min(_current_threshold + 1, thresholds.size() - 1)
		rise(thresholds[_current_threshold])
		return

	for value in thresholds:
		if _current_animated_value < value:
			_current_threshold = thresholds.find(value)
			rise(value)
			break


func rise(target_value: float) -> void:
	timer.start()

	if _active_tween:
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.tween_method(
		_set_animated_value,
		_current_animated_value,
		target_value,
		rise_duration
	).set_ease(Tween.EASE_OUT)

	_active_tween.finished.connect(_on_rise_completed.bind(), CONNECT_ONE_SHOT)


func fall() -> void:
	if _active_tween:
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.tween_method(
		_set_animated_value,
		_current_animated_value,
		0.0,
		fall_duration
	).set_ease(Tween.EASE_IN)

	_active_tween.finished.connect(_on_fall_completed, CONNECT_ONE_SHOT)


func _set_animated_value(value: float) -> void:
	_current_animated_value = value
	material.set("shader_parameter/alpha", value)


func _on_rise_completed() -> void:
	fall()


func _on_fall_completed() -> void:
	_active_tween = null


func _on_timer_timeout() -> void:
	_current_threshold = -1
