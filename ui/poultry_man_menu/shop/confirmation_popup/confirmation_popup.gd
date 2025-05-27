extends ConfirmationScreen

const CONFIRMATION_ITEM_SCENE: PackedScene = preload("uid://bsstdeorrjt66")

var existing_item_resource: Array[BaseResource]
var new_item_resource: BaseResource
var purchased_signal: Signal
var purchase_cancelled_signal: Signal

var _selected_item_resource: BaseResource # Item to remove at the end


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
	cancel_button.grab_focus()
	if existing_item_resource.is_empty():
		title.text = "Buy Item"
		_update_confirmation_text()
	else:
		title.text = "Swap Item"
		_load_items()


func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.POULTRYMAN_SHOP):
		on_cancel_button_pressed()
		# To gain focus again, toggling twice is a bit stupid though, maybe a bool
		# parameter would be more intuitive
		UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP) # Close UI
		UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP) # Open UI
		UIManager.get_viewport().set_input_as_handled()


func _load_items() -> void:
	# Empty the container content first
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for item in existing_item_resource:
		var t: ConfirmationItem = _create_confirmation_item(item)
		container.add_child(t)


# Helper function for safe instantiation
func _create_confirmation_item(display_resource: Resource, compare_resource: BaseResource = null) -> ConfirmationItem:
	if not display_resource:
		printerr("Attempted to create item with null resource")
		return null

	var item: ConfirmationItem = CONFIRMATION_ITEM_SCENE.instantiate()

	if not item or not item is ConfirmationItem:
		printerr("Failed to instantiate ConfirmationItem scene")
		return null

	item.set_item_data(display_resource, compare_resource)

	return item


func _update_confirmation_text() -> void:
	description.text = description.text % [new_item_resource.name, new_item_resource.cost]


func on_cancel_button_pressed() -> void:
	purchase_cancelled_signal.emit()
	super.on_cancel_button_pressed()


func on_confirm_button_pressed() -> void:
	purchased_signal.emit()
	close_ui()
