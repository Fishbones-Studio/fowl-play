extends Control

@onready var grid_container: GridContainer = %GridContainer

# Check for cancel button input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_button_pressed()

func _ready() -> void:
	_update_inventory()


func _update_inventory() -> void:
	await get_tree().process_frame
	
	# Empty the UI of the inventory
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()

	# Return all items in the inventory
	var inventory_items = Inventory.get_all_items()

	# Print all items in inventory
	for item in inventory_items:
		var inventory_item = load("uid://bvrmks8outcaw").instantiate()
		grid_container.add_child(inventory_item)

		# Set item properties
		inventory_item.name_label.text = item.name
		if item.icon: inventory_item.item_icon.texture = item.icon
		inventory_item.type_label.text = ItemEnums.item_type_to_string(item.type)
		inventory_item.description_label.text = item.description


func _on_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.CHICKEN_INVENTORY)


func _on_visibility_changed() -> void:
	if visible: _update_inventory()
