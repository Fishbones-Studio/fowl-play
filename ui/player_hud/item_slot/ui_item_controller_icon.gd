extends Control

# Exposed variable to set the input action name from the editor
@export var input_action: String = "":
	set(value):
		if input_action != value:
			input_action = value
			_update_controller_icon()  # Update icon when input action changes

# References the Sprite2D node for displaying the controller icon
@onready var controller_icon: Sprite2D = %Sprite2D
# Stores the original X position of the controller icon
@onready var original_x_position: float = controller_icon.position.x 

# Exposed variable to toggle showing a "Hold" label
@export var show_hold_label: bool = false:
	set(value):
		if show_hold_label != value:
			show_hold_label = value
			_update_hold_label()  # Update label visibility and icon position

# Called when the node enters the scene tree
func _ready() -> void:
	SignalManager.keybind_changed.connect(_on_keybind_changed)  # Connect to keybind change signal
	_update_controller_icon()  # Set the initial controller icon
	_update_hold_label()       # Set the initial label visibility

# Called when the keybind is changed
func _on_keybind_changed() -> void:
	_update_controller_icon()  # Refresh the controller icon

# Updates the controller icon based on the input action
func _update_controller_icon() -> void:
	if not is_inside_tree() or not controller_icon or input_action.is_empty():
		return

	var icon_path = "res://resources/controller-icons/%s.tres" % input_action.to_lower()
	var icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	
	if icon_resource and icon_resource is Texture2D:
		controller_icon.texture = icon_resource  # Apply the icon texture
	else:
		print("Failed to load icon for: ", input_action)
		controller_icon.texture = null  # Clear icon if loading fails

# Updates the visibility of the "Hold" label and adjusts icon position
func _update_hold_label() -> void:
	if not is_inside_tree() or not controller_icon:
		return

	if has_node("%HoldLabel"):
		%HoldLabel.visible = show_hold_label  # Show or hide the hold label
	
	if show_hold_label:
		controller_icon.position.x = original_x_position + 10  # Move icon if label is shown
	else:
		controller_icon.position.x = original_x_position  # Reset to original position
