extends Control

@onready var grid_container: GridContainer = %GridContainer

func _ready() -> void:
	await get_tree().process_frame
	_update_inventory()


func _update_inventory() -> void:
	# Empty the UI of the inventory
	for child in grid_container.get_children():
		child.queue_free()

	# Return all items in the inventory
	var inventory_items = Inventory.get_items()

	# Print all items in inventory
	for item in inventory_items:
		var inventory_item = load("uid://bvrmks8outcaw").instantiate()
		grid_container.add_child(inventory_item)

		# Set item properties
		inventory_item.name_label.text = item.name
		inventory_item.type_label.text = ItemEnums.item_type_to_string(item.type)
		inventory_item.description_label.text = item.description


func _on_button_pressed() -> void:
	queue_free()