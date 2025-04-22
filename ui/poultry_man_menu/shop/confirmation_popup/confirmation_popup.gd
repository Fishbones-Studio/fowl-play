extends Control

const CONFIRMATION_ITEM_SCENE = preload("uid://bsstdeorrjt66")

var existing_item_resource: BaseResource
var new_item_resource: BaseResource
var purchased_signal : Signal
var purchase_cancelled_signal : Signal

@onready var owned_items_container: CenterContainer = %OwnedItemsContainer
@onready var new_item_container: CenterContainer = %NewItemContainer


func setup(params: Dictionary) -> void:
	if "existing_item" in params:
		existing_item_resource = params["existing_item"]
	if "new_item" in params:
		new_item_resource = params["new_item"]
	if "purchased_signal" in params:
		purchased_signal = params["purchased_signal"]
	if "purchase_cancelled" in params:
		purchase_cancelled_signal = params["purchase_cancelled"]


func _ready() -> void:
	_load_items()


func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.POULTRYMAN_SHOP):
		_cancel_purchase()
		# To gain focus again, toggling twice is a bit stupid though, maybe a bool
		# parameter would work better
		UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP) 
		UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP)
		UIManager.get_viewport().set_input_as_handled()


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

	# Add to containers
	owned_items_container.add_child(current_item)
	new_item_container.add_child(new_item)

	current_item.grab_focus()


# Helper function for safe instantiation
func _create_confirmation_item(resource: Resource) -> ConfirmationItem:
	if not resource:
		printerr("Attempted to create item with null resource")
		return null

	var item: ConfirmationItem = CONFIRMATION_ITEM_SCENE.instantiate()

	if not item or not item is ConfirmationItem:
		printerr("Failed to instantiate ConfirmationItem scene")
		return null

	item.set_item_data(resource)
	item.gui_input.connect(_on_item_selected.bind(item, resource))

	return item


func _on_item_selected(event: InputEvent, item: ConfirmationItem, resource: BaseResource) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_cancel_purchase() if resource == existing_item_resource else _proceed_with_purchase()
			UIManager.get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_accept") and item.has_focus():
		_cancel_purchase() if resource == existing_item_resource else _proceed_with_purchase()


func _proceed_with_purchase() -> void:
	Inventory.remove_item(existing_item_resource)
	print("Item ", existing_item_resource, " replaced with ", new_item_resource)
	purchased_signal.emit()
	UIManager.remove_ui(self)


func _cancel_purchase() -> void:
	purchase_cancelled_signal.emit()
	UIManager.remove_ui(self)
