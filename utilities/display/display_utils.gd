class_name DisplayUtils
extends Node


static func center_window(window: Window) -> void:
	var centre_screen: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size: Vector2i = window.get_size_with_decorations()
	window.set_position(centre_screen - window_size/2)
