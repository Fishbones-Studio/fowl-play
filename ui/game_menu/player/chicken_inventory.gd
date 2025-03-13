extends Control
@onready var grid_container: GridContainer = $GridContainer

func _ready():
	update_inventory()
		
func update_inventory():
	for child in grid_container.get_children():
		child.queue_free()
		
	var inventory_items = Inventory.get_items()
	
	for item in inventory_items:
		var label = Label.new()
		label.text = item.name + " (" + item.type + ") - Cost: " + str(item.cost)
		grid_container.add_child(label)
		
