class_name InArenaShop
extends BaseShop

const IN_ARENA_SHOP_ITEM_SCENE: PackedScene = preload("uid://b1xvduw1f032y")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_inventory = false
	prevent_duplicates = false
	title_label.text = "Upgrades"
	# calls baseshop
	super()


func close_ui() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free() 


func create_shop_item(selected_item : BaseResource) -> BaseShopItem:
	var shop_item_instance: Control = IN_ARENA_SHOP_ITEM_SCENE.instantiate()

	if not shop_item_instance:
		push_error("Failed to instantiate Shop Item scene!")
		return null

	var shop_item_script_node: InArenaShopItem = shop_item_instance as InArenaShopItem
	if not shop_item_script_node:
		push_error("Instantiated shop item node does not have the expected script type.")
		shop_item_instance.queue_free()
		return null

	shop_item_script_node.set_item_data(selected_item)

	return shop_item_script_node
