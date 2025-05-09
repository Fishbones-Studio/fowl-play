# IconManager.gd
extends Node

var _icon_cache: Dictionary = {}

func get_icon_texture(action: String) -> Texture2D:
	if action.is_empty():
		return null

	if _icon_cache.has(action):
		return _icon_cache[action]

	var icon_path := "res://resources/controller-icons/%s.tres" % action.to_lower()
	var icon = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)

	if icon and icon is Texture2D:
		_icon_cache[action] = icon
		return icon
	else:
		_icon_cache[action] = null
		return null
