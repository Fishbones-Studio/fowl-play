extends Control

var current_item: Button

@onready var settings_label: Label = %SettingsLabel
@onready var content: Control = %Content

@onready var controls: Button = %Controls
@onready var key_bindings: Button = %KeyBindings
@onready var graphics: Button = %Graphics
@onready var audio: Button = %Audio

@onready var keybinds_menu: PackedScene = load("uid://bkbsjmbi2yaoh")

@onready var sidebar_items: Array[Node] = _get_sidebar_items()


func _ready() -> void:
	for item: Button in sidebar_items:
		item.toggled.connect(_on_sidebar_toggled.bind(item))
		item.focus_entered.connect(_on_focus_entered.bind(item))

	controls.grab_focus()

	SignalManager.settings_menu_toggled.emit(true)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_close_window()


func _on_focus_entered(item: Button) -> void:
	if current_item == item:
		return
		
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
			pass
	
	settings_label.text = "Settings / " + _format_text(item.name)


func _on_sidebar_toggled(toggled: bool, item: Button) -> void:
	for sidebar_item in sidebar_items:
		if sidebar_item == item:
			continue
		sidebar_item.button_pressed = false

	if toggled:
		TweenManager.create_scale_tween(null, item, Vector2(1.2, 1.2))
	else:
		TweenManager.create_scale_tween(null, item, Vector2(1.0, 1.0))


func _on_close_button_button_up() -> void:
	_close_window()


func _close_window() -> void:
	SignalManager.settings_menu_toggled.emit(false)
	queue_free()


func _get_sidebar_items() -> Array[Node]:
	return get_tree().get_nodes_in_group("SettingsMenuSidebarItem")


## Add space before capital letters that aren't at start or after existing space
func _format_text(text: String) -> String:
	var result: String = ""

	for i in range(text.length()):
		var char = text[i]

		if char == char.to_upper() and i > 0 and text[i-1] != " ":
			result += " "

		result += char

	return result
