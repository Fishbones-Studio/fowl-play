extends Control
@onready var grid_container: GridContainer = $GridContainer

func _ready():
	_update_inventory()

func _update_inventory():
	# Empty the UI of the inventory
	for child in grid_container.get_children():
		child.queue_free()
		
	# Return all items in the inventory
	var inventory_items = Inventory.get_items()
	
	# Print all items in inventory
	for item in inventory_items:
		var label = Label.new()
		label.text = item.name + " (" + item.type + ") - Cost: " + str(item.cost)
		grid_container.add_child(label)
