extends Control

@export var input_action: String = "":
	set(value):
		input_action = value
		if is_inside_tree():
			_update_controller_icon()

@onready var controller_icon: Sprite2D = $Sprite2D

func _ready() -> void:
	_update_controller_icon()

func _update_controller_icon() -> void:
	if not controller_icon or input_action.is_empty():
		return
	
	var icon_path = "res://resources/controller-icons/%s.tres" % input_action
	var icon_resource = load(icon_path)
	
	if icon_resource and icon_resource is Texture2D:
		controller_icon.texture = icon_resource
	else:
		push_warning("Failed to load controller icon for action: ", input_action)
		controller_icon.texture = null  # Clear texture if loading fails
  
