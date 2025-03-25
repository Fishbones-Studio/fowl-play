extends Control

var upgrade_items: Array[Resource]

@onready var upgrade_items_container: HBoxContainer = %ShopItemsContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.prosperity_eggs = 9000
	refresh_shop()


func refresh_shop() -> void:
	var upgrades_in_shop = 0
	while upgrades_in_shop < 5:
		var upgrade_item = load("uid://b1xvduw1f032y").instantiate()
		
		if not upgrade_item and not upgrade_item is ShopItem :
			push_error("Upgrade item path is not correctly assigned")
			return

		var random_item: Resource = UpgradeDatabase.get_random_item()
		
	
		upgrade_items.append(random_item)
		upgrade_items_container.add_child(upgrade_item)
		upgrade_item.set_item(random_item)
		
		upgrades_in_shop += 1
		
			


func close_ui() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	get_tree().paused = false 
	queue_free() 


func _on_exit_button_button_pressed() -> void:
	close_ui()
	print(GameManager.chicken_player.health)
