extends Control

@onready var button: Button = $Button

func _on_button_focus_entered() -> void:
	TweenManager.create_scale_tween(null, button, Vector2(1.2, 1.2))


func _on_button_focus_exited() -> void:
	TweenManager.create_scale_tween(null, button, Vector2(1.0, 1.0))
