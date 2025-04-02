extends Control


func _on_focus_entered() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(1.2, 1.2))


func _on_focus_exited() -> void:
	TweenManager.create_scale_tween(null, self, Vector2(1.0, 1.0))
