extends Control

@export var input_action: String = "":
	set(value):
		if input_action != value:
			input_action = value
			_update_controller_icon()

@export var show_hold_label: bool = false:
	set(value):
		if show_hold_label != value:
			show_hold_label = value
			_update_hold_label()

@onready var controller_icon: Sprite2D = %Sprite2D
@onready var original_x_position: float = controller_icon.position.x

func _ready() -> void:
	SignalManager.keybind_changed.connect(_on_keybind_changed)
	_update_controller_icon()
	_update_hold_label()

func _on_keybind_changed() -> void:
	# clear cache and reload this icon
	IconManager.clear_cache()
	_update_controller_icon()

func _update_controller_icon() -> void:
	if not is_inside_tree() or not controller_icon or input_action.is_empty():
		return

	var tex: Texture2D = IconManager.get_icon_texture(input_action)
	controller_icon.texture = tex
	controller_icon.visible = tex != null

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
