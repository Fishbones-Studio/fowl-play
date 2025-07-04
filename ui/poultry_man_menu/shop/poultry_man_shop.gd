extends BaseShop

const SHOP_ITEM_SCENE: PackedScene = preload("uid://cc5vmtbby4xy0")


func _ready() -> void:
	check_inventory = true
	prevent_duplicates = true
	shop_title_label.text = "Equipment Shop"
	super()


func create_shop_item(selected_item : BaseResource) -> BaseShopItem:
	var shop_item_instance: Node = SHOP_ITEM_SCENE.instantiate()

	if not shop_item_instance:
		push_error("Failed to instantiate Shop Item scene!")
		return null

	var shop_item_script_node: ShopItem = shop_item_instance as ShopItem

	if not shop_item_script_node:
		push_error("Instantiated shop item node does not have the expected script type.")
		shop_item_instance.queue_free()
		return null

	shop_item_script_node.set_item_data(selected_item)

	return shop_item_script_node


func _on_close_button_pressed()-> void:
	UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP)
