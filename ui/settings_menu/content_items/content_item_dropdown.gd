class_name ContentItemDropdown
extends ContentItem

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var options: OptionButton = $MarginContainer/HBoxContainer/Panel/OptionButton
@onready var panel: Panel = $MarginContainer2/Panel


func _on_focus_entered() -> void:
	options.grab_focus()


func _on_option_button_focus_entered() -> void:
	_set_neighbors_for(options)
	_toggle_active(panel, true)


func _on_option_button_focus_exited() -> void:
	_toggle_active(panel, false)
