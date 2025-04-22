class_name SettingsMenu extends Control

@onready var settings_label: Label = %SettingsLabel
@onready var content: Control = %Content

@onready var controls: Button = %Controls
@onready var key_bindings: Button = %KeyBindings
@onready var graphics: Button = %Graphics
@onready var audio: Button = %Audio
@onready var cheat: Button = %Cheat

@onready var keybinds_menu: PackedScene = preload("uid://bkbsjmbi2yaoh")
@onready var audio_menu: PackedScene = preload("uid://6xd2kic6u58a")
@onready var cheat_menu: PackedScene = preload("uid://b8gcj7dpmbadg")

@onready var sidebar_container: VBoxContainer = %SidebarContainer


func _ready() -> void:
	for item: SiderBarItem in sidebar_container.get_children():
		item.focus_entered.connect(_on_sidebar_focus_entered.bind(item))

	# Remove cheat menu if not in debug
	if not OS.has_feature("debug"):
		cheat.queue_free()

	controls.grab_focus()


func _input(event: InputEvent) -> void:
	# Remove settings menu, and make pause focusable again, if conditions are true
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.PAUSE_MENU):
		UIManager.remove_ui(self)
		UIManager.handle_pause()
		UIManager.get_viewport().set_input_as_handled()


func _on_sidebar_focus_entered(sidebar_item: SiderBarItem) -> void:
	for item: SiderBarItem in sidebar_container.get_children():
		item.active = item == sidebar_item

	_update_content(sidebar_item)


func _on_close_button_button_up() -> void:
	UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)


func _update_content(sidebar_item: SiderBarItem) -> void:
	for child in content.get_children():
		content.remove_child(child)

	match sidebar_item:
		controls:
			pass
		key_bindings:
			content.add_child(keybinds_menu.instantiate())
		graphics:
			pass
		audio:
			content.add_child(audio_menu.instantiate())
		cheat:
			content.add_child(cheat_menu.instantiate())

	settings_label.text = "Settings / " + _format_text(sidebar_item.name)


# Add space before capital letters that aren't at start or after existing space
func _format_text(text: String) -> String:
	var result: String = ""

	for i in range(text.length()):
		var character = text[i]

		if character == character.to_upper() and i > 0 and text[i-1] != " ":
			result += " "

		result += character

	return result
