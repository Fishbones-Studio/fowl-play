extends Control
@onready var shop_slots: HBoxContainer = $shop_slots

func _ready():
	GameManager.prosperity_eggs = 9000
	randomize()
	refresh_shop()


#Function to refresh the shop

func refresh_shop():
	#loop over the shop_slots to get all the Item_Templates and fill them with a item
	
	for slot in shop_slots.get_children():
		if slot == null:
			print("Error: Found a Nil slot!")
			continue
			
		if slot is Item_Template:
			var random_item = ItemDatabase.get_random_item()
			slot.set_item(random_item)


func _on_button_pressed():

	queue_free()
