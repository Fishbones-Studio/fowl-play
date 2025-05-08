class_name RestoreDefaultsButton
extends Button

@onready var stylebox_focus: StyleBoxFlat = load("uid://dwicgkvjluob0")


func _on_button_up() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(1.0, 1.0))
	add_theme_stylebox_override("focus", stylebox_focus)


func _on_button_down() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(0.9, 0.9))
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
