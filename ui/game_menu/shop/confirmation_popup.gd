extends Control

signal confirmed(new_item)
signal canceled

@onready var existing_item_name: Label = $HBoxContainer/VBoxContainerExisting/existing_item_name
@onready var existing_item_buff: Label = $HBoxContainer/VBoxContainerExisting/existing_item_buff
@onready var existing_item_type: Label = $HBoxContainer/VBoxContainerExisting/existing_item_type
@onready var existing_item_cost: Label = $HBoxContainer/VBoxContainerExisting/existing_item_cost

@onready var new_item_name: Label = $HBoxContainer/VBoxContainerNew/new_item_name
@onready var new_item_buff: Label = $HBoxContainer/VBoxContainerNew/new_item_buff
@onready var new_item_type: Label = $HBoxContainer/VBoxContainerNew/new_item_type
@onready var new_item_cost: Label = $HBoxContainer/VBoxContainerNew/new_item_cost

var pending_item = null #Variable to store the item in waiting for conformation

func show_confirmation(existing_item: Dictionary, new_item : Dictionary):
	pending_item = new_item
	
	existing_item_name.text = existing_item.name
	existing_item_type.text = existing_item.type
	existing_item_cost.text = "Cost: " + str(existing_item.cost)
	
	new_item_name.text = new_item.name
	new_item_type.text = new_item.type
	new_item_cost.text = "Cost: " + str(new_item.cost)
	
	visible = true
	


func _on_replace_pressed() -> void:
	emit_signal("confirmed", pending_item)
	visible = false


func _on_cancel_pressed() -> void:
	emit_signal("canceled")
	visible = false
