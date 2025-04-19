class_name SiderBarItem
extends Button

var active: bool = false:
	set(value):
		if value:
			TweenManager.create_scale_tween(null, self, Vector2(1.2, 1.2))
			add_theme_color_override("font_disabled_color", Color("#efecee"))
		else:
			TweenManager.create_scale_tween(null, self, Vector2(1.0, 1.0))
			add_theme_color_override("font_disabled_color", Color("#bebcbe"))
