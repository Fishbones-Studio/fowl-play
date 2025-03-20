class_name ShopItem
extends PanelContainer

var purchase_in_progress : bool = false
var shop_item : Resource

@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel


func set_item(item: Resource) -> void:
	name_label.text = item.name
	type_label.text =  ItemDatabase.item_type_to_string(item.type)
	cost_label.text = str(item.cost)
	description_label.text = item.description
	
	shop_item = item


func _buy_item() -> void:
	if purchase_in_progress:
		return
	
	# Prevent the purchase from happening multiple times
	purchase_in_progress = true
	
	if GameManager.prosperity_eggs < int(cost_label.text):
		print("Not enough Prosperity Eggs. Current Prosperity Eggs: ", GameManager.prosperity_eggs)
		purchase_in_progress = false
		return
	
	ItemDatabase.get_item(shop_item)
	
	var existing_items: Array[Resource] = Inventory.get_item_by_type(shop_item.type)
	
	for item in existing_items:
		if item == shop_item:
			print("Item already owned")
			purchase_in_progress = false
			return
	
	# Max items of same type is 2
	if existing_items.size() < 2:
		Inventory.add_item(shop_item)
		GameManager.update_prosperity_eggs(-int(cost_label.text))
		
		print("Item bought: ", shop_item)
		purchase_in_progress = false
		return
		
	var matching_items: int = 0
	
	for item in existing_items:
		if item.type == shop_item.type:
			matching_items += 1

	if matching_items >= 2:
		SignalManager.add_ui_scene.emit("uid://da6m7g6ijjyop", {
			"existing_items": existing_items,
			"new_item": shop_item,
			})
		purchase_in_progress = false


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_buy_item()
