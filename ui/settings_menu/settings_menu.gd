extends Control

var current_item: Button

@onready var settings_label: Label = %SettingsLabel
@onready var content: Control = %Content

@onready var controls: Button = %Controls
@onready var key_bindings: Button = %KeyBindings
@onready var graphics: Button = %Graphics
@onready var audio: Button = %Audio

@onready var keybinds_menu: PackedScene = load("uid://bkbsjmbi2yaoh")
@onready var audio_menu: PackedScene = load("uid://6xd2kic6u58a")

@onready var sidebar_items: Array[Node] = _get_sidebar_items()


func _ready() -> void:
	for item: Button in sidebar_items:
		item.toggled.connect(_on_sidebar_toggled.bind(item))
		item.focus_entered.connect(_on_sidebar_focus_entered.bind(item))
		item.pressed.connect(_on_sidebar_pressed.bind(item))

	controls.grab_focus()


func _on_sidebar_pressed(item: Button) -> void:
	if current_item != item:
		return

	item.button_pressed = true
	current_item = item


func _on_sidebar_focus_entered(item: Button) -> void:
	item.button_pressed = true
	current_item = item

	_update_content(item)


func _update_content(item: Button) -> void:
	for child in content.get_children():
		content.remove_child(child)
	
	match item:
		controls:
			pass
		key_bindings:
			content.add_child(keybinds_menu.instantiate())
		graphics:
			pass
		audio:
			content.add_child(audio_menu.instantiate())
	
	settings_label.text = "Settings / " + _format_text(item.name)


func _on_sidebar_toggled(_toggled: bool, item: Button) -> void:
	for sidebar_item in sidebar_items:
		if sidebar_item == item:
			TweenManager.create_scale_tween(null, sidebar_item, Vector2(1.2, 1.2))
			continue
		sidebar_item.button_pressed = false
		TweenManager.create_scale_tween(null, sidebar_item, Vector2(1.0, 1.0))


func _on_close_button_button_up() -> void:
	UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)


func _get_sidebar_items() -> Array[Node]:
	return get_tree().get_nodes_in_group("SettingsMenuSidebarItem")


# Add space before capital letters that aren't at start or after existing space
func _format_text(text: String) -> String:
	var result: String = ""

	for i in range(text.length()):
		var character = text[i]

		if character == character.to_upper() and i > 0 and text[i-1] != " ":
			result += " "

		result += character

	return result
