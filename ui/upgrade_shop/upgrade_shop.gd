class_name UpgradeShop
extends BaseShop

const UPGRADE_SHOP_ITEM_SCENE: PackedScene = preload("uid://b1xvduw1f032y")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_inventory = false
	prevent_duplicates = false
	shop_title_label.text = "Upgrades Shop"

	SignalManager.upgrades_shop_refreshed.connect(_refresh_shop)

	super()


func create_shop_item(selected_item : BaseResource) -> BaseShopItem:
	var shop_item_instance: Control = UPGRADE_SHOP_ITEM_SCENE.instantiate()

	if not shop_item_instance:
		push_error("Failed to instantiate Shop Item scene!")
		return null

	var shop_item_script_node: UpgradeShopItem = shop_item_instance as UpgradeShopItem
	if not shop_item_script_node:
		push_error("Instantiated shop item node does not have the expected script type.")
		shop_item_instance.queue_free()
		return null

	shop_item_script_node.set_item_data(selected_item)

	return shop_item_script_node


func _on_close_button_pressed()-> void:
	UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
