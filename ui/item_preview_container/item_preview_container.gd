class_name ItemPreviewContainer 
extends VBoxContainer

@export var scroll_speed: int = 15

var _current_item: BaseResource

@onready var shop_preview_label: Label = %ItemPreviewLabel
@onready var shop_preview_icon: TextureRect = %ItemPreviewIcon
@onready var shop_preview_type: Label = %ItemPreviewType
@onready var shop_preview_description: RichTextLabel = %ItemPreviewDescription
@onready var shop_preview_description_container: HBoxContainer = %ItemPreviewDescriptionToggle
@onready var shop_preview_description_toggle_button: CheckButton = %ItemPreviewDescriptionToggleButton
@onready var scroll_container: ScrollContainer = $ScrollContainer


func _ready() -> void:
	shop_preview_description_toggle_button.add_to_group("shop_item") # Whack, but we don't want to lose focus if clicking the check button
	shop_preview_description_toggle_button.toggled.connect(_on_update_description)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and shop_preview_description_container.visible:
		shop_preview_description_toggle_button.button_pressed = !shop_preview_description_toggle_button.button_pressed
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_container.scroll_vertical -= scroll_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_container.scroll_vertical += scroll_speed
	if event is InputEventJoypadMotion:
		var scroll_direction: float = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		if sign(scroll_direction): # Down
			scroll_container.scroll_vertical -= scroll_speed
		if not sign(scroll_direction): # Up
			scroll_container.scroll_vertical += scroll_speed


func setup(item: BaseResource) -> void:
	await get_tree().process_frame

	_current_item = item

	shop_preview_label.text = item.name
	if item.icon:
		shop_preview_icon.texture = item.icon
	shop_preview_type.text = ItemEnums.item_type_to_string(item.type)

	if item.short_description.is_empty():
		shop_preview_description_container.hide()
	else:
		shop_preview_description_container.show()
	_on_update_description(shop_preview_description_toggle_button.button_pressed)


func _on_update_description(toggled_on: bool) -> void:
	if toggled_on:
		shop_preview_description.text = _current_item.short_description
	else:
		shop_preview_description.text = _current_item.description % _current_item.get_modifier_string()
