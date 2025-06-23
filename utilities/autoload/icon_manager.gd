extends Node

var _icon_cache: Dictionary = {}


# Public: get the icon texture for a given action name
func get_icon_texture(action: String) -> Texture2D:
	if action.is_empty():
		return null

	action = action.to_lower()
	if _icon_cache.has(action):
		return _icon_cache[action]

	var path: String = "res://resources/controller-icons/%s.tres" % action
	var tex: Resource = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	if tex and tex is Texture2D:
		_icon_cache[action] = tex
		return tex

	_icon_cache[action] = null
	return null


# clear entire cache or just one entry
func clear_cache(action_name: String = "*") -> void:
	if action_name == "*":
		_icon_cache.clear()
	else:
		_icon_cache.erase(action_name.to_lower())
