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

@export var show_switch_icon: bool = false:
	set(value):
		if show_switch_icon != value:
			show_switch_icon = value
			_update_switch_icon()

@onready var controller_icon: Sprite2D = %Sprite2D
@onready var original_x_position: float = controller_icon.position.x
@onready var weapon_switch_icon: Sprite2D = %weapon_switch_icon


func _ready() -> void:
	SignalManager.keybind_changed.connect(_on_keybind_changed)
	_update_controller_icon()
	_update_hold_label()


func _on_keybind_changed(action_name: String) -> void:
	if action_name == "*" or action_name.to_lower() == input_action.to_lower():
		IconManager.clear_cache(input_action)
		_update_controller_icon()


func _update_controller_icon() -> void:
	if not is_inside_tree() or not controller_icon or input_action.is_empty():
		return

	var tex: Texture2D = IconManager.get_icon_texture(input_action)
	controller_icon.texture = tex
	controller_icon.visible = tex != null


func _update_hold_label() -> void:
	if not is_inside_tree() or not controller_icon:
		return

	if has_node("%HoldLabel"):
		%HoldLabel.visible = show_hold_label

	controller_icon.position.x = original_x_position + 10 if show_hold_label else original_x_position


func _update_switch_icon() -> void:
	if not is_inside_tree() or not controller_icon:
		return

	if has_node("%weapon_switch_icon"):
		weapon_switch_icon.visible = show_switch_icon
