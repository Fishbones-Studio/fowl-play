extends Control

@export var input_action: String = "":
	set(value):
		input_action = value
		if is_inside_tree():
			_update_controller_icon()

@onready var controller_icon: Sprite2D = $Sprite2D

func _ready() -> void:
	print("Connecting to keybind_changed for ", input_action)
	SignalManager.keybind_changed.connect(_update_controller_icon)
	_update_controller_icon()

func _update_controller_icon() -> void:
	print("Keybind changed! Updating icon for: ", input_action)
	
	if not is_instance_valid(controller_icon) or input_action.is_empty():
		if controller_icon:
			controller_icon.texture = null
		return

	var icon_path = "res://resources/controller-icons/%s.tres" % input_action.to_lower()
	var icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) # Bypass cache
	
	if not icon_resource:
		icon_path = "res://resources/controller-icons/%s.png" % input_action.to_lower()
		icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) # Bypass cache

	if icon_resource and icon_resource is Texture2D:
		controller_icon.texture = icon_resource
	else:
		print("Failed to load icon for: ", input_action)
		controller_icon.texture = null

  
