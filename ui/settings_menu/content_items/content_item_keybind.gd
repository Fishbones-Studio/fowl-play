class_name ContentItemKeybind
extends ContentItem

var _next_item: ContentItem = null
var _prev_item: ContentItem = null

@onready var primary_button: Button = %PrimaryButton
@onready var secondary_button: Button = %SecondaryButton
@onready var controller_button: Button = %ControllerButton
@onready var panel: Panel = %Panel
@onready var controller_panel: RemapPanel = $MarginContainer/HBoxContainer/ControllerPanel


func _on_focus_entered() -> void:
	primary_button.grab_focus()


func _on_button_focus_entered(index: int) -> void:
	_toggle_active(panel, true)

	_set_neighbors_for(primary_button)
	_set_neighbors_for(secondary_button)
	_set_neighbors_for(controller_button)

	var top_neighbor: Node = get_node(focus_neighbor_top)
	if top_neighbor is ContentItemKeybind:
		_prev_item = top_neighbor

	var bottom_neighbor: Node = get_node(focus_neighbor_bottom)
	if bottom_neighbor is ContentItemKeybind:
		_next_item = bottom_neighbor

	match index:
		1:
			if _prev_item:
				primary_button.focus_neighbor_top = _prev_item.primary_button.get_path()
			if _next_item:
				primary_button.focus_neighbor_bottom = _next_item.primary_button.get_path()
			primary_button.focus_neighbor_right = secondary_button.get_path()
			primary_button.focus_neighbor_left = controller_button.get_path()
		2:
			if _prev_item:
				secondary_button.focus_neighbor_top = _prev_item.secondary_button.get_path()
			if _next_item:
				secondary_button.focus_neighbor_bottom = _next_item.secondary_button.get_path()
			if controller_panel.visible:
				secondary_button.focus_neighbor_right = controller_button.get_path()
			secondary_button.focus_neighbor_left = primary_button.get_path()
		3:
			if _prev_item:
				controller_button.focus_neighbor_top = _prev_item.controller_button.get_path()
			if _next_item:
				controller_button.focus_neighbor_bottom = _next_item.controller_button.get_path()
			controller_button.focus_neighbor_right = primary_button.get_path()
			controller_button.focus_neighbor_left = secondary_button.get_path()


func _on_button_focus_exited() -> void:
	if primary_button.has_focus():
		return
	if secondary_button.has_focus():
		return
	if controller_button.has_focus():
		return

	_toggle_active(panel, false)
