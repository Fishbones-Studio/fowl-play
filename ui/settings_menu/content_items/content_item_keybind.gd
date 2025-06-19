extends ContentItem

@onready var primary_button: Button = %PrimaryButton
@onready var secondary_button: Button = %SecondaryButton
@onready var controller_button: Button = %ControllerButton

@onready var panel: Panel = %Panel


func _on_focus_entered() -> void:
	primary_button.grab_focus()


func _on_button_focus_entered(index: int) -> void:
	_toggle_active(panel, true)

	_set_neighbors_for(primary_button)
	_set_neighbors_for(secondary_button)
	_set_neighbors_for(controller_button)

	match index:
		1:
			primary_button.focus_neighbor_right = secondary_button.get_path()
			primary_button.focus_neighbor_left = controller_button.get_path()
		2:
			secondary_button.focus_neighbor_right = controller_button.get_path()
			secondary_button.focus_neighbor_left = primary_button.get_path()
		3:
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
