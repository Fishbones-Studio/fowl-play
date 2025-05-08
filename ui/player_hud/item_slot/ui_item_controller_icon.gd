extends Control

@export var input_action: String = "":
	set(value):
		input_action = value
		if is_inside_tree():
			_update_controller_icon()

@onready var controller_icon: Sprite2D = $Sprite2D
@onready var original_x_position: float = controller_icon.position.x 

@export var show_hold_label: bool = false:
	set(value):
		show_hold_label = value
		if is_inside_tree() and controller_icon:
			if has_node("%HoldLabel"):
				%HoldLabel.visible = show_hold_label
			
			# Set position based on hold label visibility
			if show_hold_label:
				controller_icon.position.x = original_x_position + 10  # Move right 10 pixels
			else:
				controller_icon.position.x = original_x_position  # Return to original position

func _ready() -> void:
	print("Connecting to keybind_changed for ", input_action)
	SignalManager.keybind_changed.connect(_update_controller_icon)
	_update_controller_icon()
	
	# Initialize hold label visibility and position
	if has_node("%HoldLabel"):
		%HoldLabel.visible = show_hold_label
	if controller_icon:
		controller_icon.position.x = original_x_position + (10 if show_hold_label else 0)

func _update_controller_icon() -> void:
	print("Keybind changed! Updating icon for: ", input_action)
	
	if not is_instance_valid(controller_icon) or input_action.is_empty():
		if controller_icon:
			controller_icon.texture = null
		return

	var icon_path = "res://resources/controller-icons/%s.tres" % input_action.to_lower()
	var icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	
	if not icon_resource:
		icon_path = "res://resources/controller-icons/%s.png" % input_action.to_lower()
		icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)

	if icon_resource and icon_resource is Texture2D:
		controller_icon.texture = icon_resource
	else:
		print("Failed to load icon for: ", input_action)
		controller_icon.texture = null
