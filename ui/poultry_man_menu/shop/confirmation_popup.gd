extends Control

var existing_items: Array[BaseResource]
var new_item: Resource

@onready var owned_items_container: HBoxContainer = %OwnedItemsContainer
@onready var new_item_container: VBoxContainer = %NewItemContainer


func _ready() -> void:
	_load_items()


func setup(params: Dictionary) -> void:
	if "existing_items" in params:
		existing_items = params["existing_items"]
	if "new_item" in params:
		new_item = params["new_item"]


func _load_items() -> void:
	existing_items.append(new_item)

	for item in existing_items:
		var current_item: ShopItem = load("uid://cc5vmtbby4xy0").instantiate()

		# Check if current_item is valid
		if not current_item:
			print("Failed to instantiate ShopItem.")
			continue

		var shop_item_vbox: Node = current_item.get_child(-1)

		if item != new_item:
			# Add the replace- and cancel buttons to the item
			var h_separator = HSeparator.new()

			var replace_button = Button.new()
			replace_button.text = "Replace"
			replace_button.button_up.connect(_replace_item.bind(item, new_item))

			shop_item_vbox.add_child(h_separator)
			shop_item_vbox.add_child(replace_button)

			replace_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			replace_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

			owned_items_container.add_child(current_item)
		else:
			new_item_container.add_child(current_item)

		# Set item properties
		current_item.name_label.text = item.name
		current_item.type_label.text = ItemEnums.item_type_to_string(item.type)
		current_item.description_label.text = item.description
		current_item.cost_label.text = str(item.cost)
		current_item.make_unclickable()


func _replace_item(old_item: Resource, _new_item: Resource) -> void:
	Inventory.remove_item(old_item)
	Inventory.add_item(_new_item)
	GameManager.update_prosperity_eggs(-_new_item.cost)

	print("Item ", old_item, " replaced with ", _new_item)
	queue_free()


func _on_cancel_button_button_up() -> void:
	queue_free()
