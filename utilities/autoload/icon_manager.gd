extends Node

# Simple cache so we don't hammer the disk every frame
var _icon_cache: Dictionary = {}

func _ready() -> void:
	# whenever keybinds change, we want to reload our icons
	SignalManager.keybind_changed.connect(clear_cache)

# Public: get the icon texture for a given action name
func get_icon_texture(action: String) -> Texture2D:
	if action.is_empty():
		return null

	action = action.to_lower()
	if _icon_cache.has(action):
		return _icon_cache[action]

	var path := "res://resources/controller-icons/%s.tres" % action
	var tex := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	if tex and tex is Texture2D:
		_icon_cache[action] = tex
		return tex

	# cache null so we don’t retry every frame
	_icon_cache[action] = null
	return null

# Public: clear everything in the cache
func clear_cache() -> void:
	_icon_cache.clear()
