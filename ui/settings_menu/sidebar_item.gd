class_name SideBarItem
extends Button

var _was_already_active: bool = false  # Track previous state
var active: bool = false:
	set(value):
		# Store whether it was already active BEFORE changing
		_was_already_active = active

		active = value
		if value:
			TweenManager.create_scale_tween(null, self, Vector2(1.2, 1.2))
			add_theme_color_override("font_disabled_color", Color("#efecee"))

			# Only shake if it was already active before this change
			if _was_already_active:
					var jump_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
					jump_tween.tween_property(self, "position:y", position.y - 10, 0.15) # Quick jump up
					jump_tween.tween_property(self, "position:y", position.y + 5, 0.2)  # Bounce down with overshoot
					jump_tween.tween_property(self, "position:y", position.y, 0.25) # Settle back to normal position

					# Add little rotation wobble for extra happiness
					var rotate_tween = create_tween()
					rotate_tween.tween_property(self, "rotation_degrees", -3, 0.1)
					rotate_tween.tween_property(self, "rotation_degrees", 3, 0.2)
					rotate_tween.tween_property(self, "rotation_degrees", 0, 0.1)

					var scale_tween = TweenManager.create_scale_tween(null, self, Vector2(1.25, 1.25), 0.1)
					TweenManager.create_scale_tween(null, self, Vector2(1.2, 1.2), 0.3)
		else:
			TweenManager.create_scale_tween(null, self, Vector2(1.0, 1.0))
			add_theme_color_override("font_disabled_color", Color("#bebcbe"))
