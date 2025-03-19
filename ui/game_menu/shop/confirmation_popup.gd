extends Control

signal confirmed(new_item)
signal canceled

@onready var existing_item_name: Label = $HBoxContainer/VBoxContainerExisting1/existing_item_name
@onready var existing_item_buff: Label = $HBoxContainer/VBoxContainerExisting1/existing_item_buff
@onready var existing_item_type: Label = $HBoxContainer/VBoxContainerExisting1/existing_item_type
@onready var existing_item_cost: Label = $HBoxContainer/VBoxContainerExisting1/existing_item_cost
@onready var replace_item_1: Button = $HBoxContainer/VBoxContainerExisting1/replace_item1
@onready var cancel1: Button = $HBoxContainer/VBoxContainerExisting1/cancel

@onready var existing_item2_label: Label = $HBoxContainer/VBoxContainerExisting2/Label
@onready var existing_item_name2: Label = $HBoxContainer/VBoxContainerExisting2/existing_item_name
@onready var existing_item_buff2: Label = $HBoxContainer/VBoxContainerExisting2/existing_item_buff
@onready var existing_item_type2: Label = $HBoxContainer/VBoxContainerExisting2/existing_item_type
@onready var existing_item_cost2: Label = $HBoxContainer/VBoxContainerExisting2/existing_item_cost
@onready var replace_item_2: Button = $HBoxContainer/VBoxContainerExisting2/replace_item2
@onready var cancel2: Button = $HBoxContainer/VBoxContainerExisting2/cancel

@onready var new_item_name: Label = $HBoxContainer/VBoxContainerNew/new_item_name
@onready var new_item_buff: Label = $HBoxContainer/VBoxContainerNew/new_item_buff
@onready var new_item_type: Label = $HBoxContainer/VBoxContainerNew/new_item_type
@onready var new_item_cost: Label = $HBoxContainer/VBoxContainerNew/new_item_cost

var pending_item = null #Variable to store the item in waiting for conformation

func show_confirmation(existing_item, new_item : Dictionary):
	pending_item = new_item
	if existing_item is Array and existing_item.size() == 2:
		existing_item_name.text = existing_item[0].name
		existing_item_type.text = existing_item[0].type
		existing_item_cost.text = str(existing_item[0].cost)
		
		existing_item_name2.text = existing_item[1].name
		existing_item_type2.text = existing_item[1].type
		existing_item_cost2.text = str(existing_item[1].cost)
		replace_item_1.visible = true
		replace_item_2.visible = true
		
		new_item_name.text = new_item.name
		new_item_type.text = new_item.type
		new_item_cost.text = str(new_item.cost)
		
		cancel1.pressed.connect(func(): _on_cancel_pressed())
		cancel2.pressed.connect(func(): _on_cancel_pressed())
		replace_item_1.pressed.connect(func(): _on_replace_pressed(existing_item[0], new_item))
		replace_item_2.pressed.connect(func(): _on_replace_pressed(existing_item[1], new_item))
	else:
		existing_item_name.text = existing_item[0].name
		existing_item_type.text = existing_item[0].type
		existing_item_cost.text = str(existing_item[0].cost)
		
		new_item_name.text = new_item.name
		new_item_type.text = new_item.type
		new_item_cost.text = str(new_item.cost)
		
		replace_item_1.visible = true
		replace_item_2.visible = false
		existing_item2_label.visible = false
		cancel2.visible = false
		replace_item_1.pressed.connect(func(): _on_replace_pressed(existing_item, new_item))
		cancel1.pressed.connect(func(): _on_cancel_pressed())
	
	visible = true
	


func _on_replace_pressed(old_item: Array , new_item: Dictionary) -> void:
	emit_signal("confirmed", old_item, new_item)
	visible = false


func _on_cancel_pressed() -> void:
	emit_signal("canceled")
	visible = false
