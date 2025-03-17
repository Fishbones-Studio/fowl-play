extends Control

@onready var shop_slots: HBoxContainer = $ShopSlots


func _ready():
	randomize()
	refresh_shop()


func refresh_shop():
	#Loop over the shop_slots to get all the Item_Templates and fill them with a item
	for slot in shop_slots.get_children():
		if slot == null:
			print("Error: Found a Nil slot!")
			continue
			
		if slot is Item_Template:
			var random_item = ItemDatabase.get_random_item()
			slot.set_item(random_item)


func _on_exit_button_pressed() -> void:
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
