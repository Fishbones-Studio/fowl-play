class_name InArenaShop
extends BaseShop


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_scene = load("uid://b1xvduw1f032y")
	shop_items_container = %ShopItemsContainer
	check_inventory = false  
	prevent_duplicates = false  
	# calls baseshop
	super()


func close_ui() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	get_tree().paused = false 
	queue_free() 


func _on_exit_button_button_pressed() -> void:
	close_ui()
