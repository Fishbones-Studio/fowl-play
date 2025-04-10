extends Control

const CONFIRMATION_ITEM_SCENE = preload("uid://bsstdeorrjt66")

var existing_item_resource: BaseResource
var new_item_resource: BaseResource

@onready var owned_items_container: CenterContainer = %OwnedItemsContainer
@onready var new_item_container: CenterContainer = %NewItemContainer

func setup(params: Dictionary) -> void:
	print("Confirmation popup setup with params: ", params)
	if "existing_item" in params:
		existing_item_resource = params["existing_item"]
	if "new_item" in params:
		new_item_resource = params["new_item"]
		

func _ready() -> void:
	_load_items()

func _load_items() -> void:
	if new_item_resource == null:
		printerr("Item is null")
		return 

	# Safely instantiate and setup items
	var current_item: ConfirmationItem = _create_confirmation_item(existing_item_resource)
	var new_item: ConfirmationItem = _create_confirmation_item(new_item_resource)

	# Verify successful creation
	if not current_item or not new_item:
		printerr("Failed to create one or more confirmation items")
		# Clean up any partially created items
		if current_item: current_item.queue_free()
		if new_item: new_item.queue_free()
		return
		
	current_item.make_unclickable()

	# Add to containers
	owned_items_container.add_child(current_item)
	new_item_container.add_child(new_item)


# Helper function for safe instantiation
func _create_confirmation_item(resource: Resource) -> ConfirmationItem:
	if not resource:
		printerr("Attempted to create item with null resource")
		return null

	var item : ConfirmationItem = CONFIRMATION_ITEM_SCENE.instantiate()
	if not item or not item is ConfirmationItem:
		printerr("Failed to instantiate ConfirmationItem scene")
		return null
		
	item.set_item_data(resource)
	return item

func _replace_item(old_item: Resource, _new_item: Resource) -> void:
	Inventory.remove_item(old_item)
	Inventory.add_item(_new_item)
	GameManager.update_prosperity_eggs(-_new_item.cost)

	print("Item ", old_item, " replaced with ", _new_item)
	queue_free()

func _on_cancel_button_button_up() -> void:
	queue_free()


func _on_replace_button_pressed() -> void:
	_replace_item(existing_item_resource, new_item_resource)
