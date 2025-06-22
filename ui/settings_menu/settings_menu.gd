class_name SettingsMenu
extends UserInterface

var focused_sidebar_item: SideBarItem = null

@onready var settings_label: Label = %SettingsLabel
@onready var content: Control = %Content

@onready var controls: Button = %Controls
@onready var key_bindings: Button = %KeyBindings
@onready var graphics: Button = %Graphics
@onready var audio: Button = %Audio
@onready var cheat: Button = %Cheat

@onready var controls_menu: PackedScene = preload("uid://cq223dym52whr")
@onready var keybinds_menu: PackedScene = preload("uid://bkbsjmbi2yaoh")
@onready var graphics_menu: PackedScene = preload("uid://dcr1ox6uqifst")
@onready var audio_menu: PackedScene = preload("uid://6xd2kic6u58a")
@onready var cheat_menu: PackedScene = preload("uid://b8gcj7dpmbadg")

@onready var sidebar_container: VBoxContainer = %SidebarContainer
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	for item: SideBarItem in sidebar_container.get_children():
		item.focus_entered.connect(_on_sidebar_focus_entered.bind(item))

	# Remove cheat menu if not in debug
	if not OS.has_feature("debug"):
		cheat.queue_free()

	controls.grab_focus()

	audio.focus_neighbor_bottom = cheat.get_path() if cheat else controls.get_path()
	audio.focus_next = cheat.get_path() if cheat else controls.get_path()

	super()


func _input(_event: InputEvent) -> void:
	# Remove settings menu, and make pause focusable again, if conditions are true
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		_on_close_button_pressed()


func _on_sidebar_focus_entered(sidebar_item: SideBarItem) -> void:
	for item: SideBarItem in sidebar_container.get_children():
		item.active = item == sidebar_item
		if item.active: focused_sidebar_item = item

	_update_content(sidebar_item)


func _on_close_button_pressed() -> void:
	UIManager.remove_ui(self)
	var pause_menu: Control = UIManager.ui_list.get(UIEnums.UI.PAUSE_MENU)
	if pause_menu: UIManager.current_ui = pause_menu
	UIManager.get_viewport().set_input_as_handled()

	SignalManager.focus_lost.emit()


func _update_content(sidebar_item: SideBarItem) -> void:
	for child in content.get_children():
		content.remove_child(child)

	match sidebar_item:
		controls:
			content.add_child(controls_menu.instantiate())
		key_bindings:
			content.add_child(keybinds_menu.instantiate())
		graphics:
			content.add_child(graphics_menu.instantiate())
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


func _on_content_focus_entered() -> void:
	var content_container: VBoxContainer = content.find_child("ContentContainer", true, false)
	var restore_defaults_button: RestoreDefaultsButton = content.find_child("RestoreDefaultsButton", true, false)
	var children: Array[Node] = content_container.get_children()

	var first_child: Control = children[0]

	for index in children.size():
		var child: Control = children[index]

		if index > 0:
			# Set focus_previous to the previous child
			child.focus_neighbor_top = children[index - 1].get_path()
			child.focus_previous = child.focus_neighbor_top # TODO: Doesn't seem to work
		else:
			# Set focus and neighbor top for first child
			child.focus_neighbor_top = focused_sidebar_item.get_path()
			child.focus_previous = child.focus_neighbor_top # TODO: Doesn't seem to work

		if index == children.size() - 1:
			# Set neighbor for last child
			child.focus_neighbor_bottom = restore_defaults_button.get_path() if restore_defaults_button else first_child.get_path()
			child.focus_next = restore_defaults_button.get_path() if restore_defaults_button else first_child.get_path()
		else:
			child.focus_neighbor_bottom = children[index + 1].get_path()
			child.focus_next = child.focus_neighbor_bottom # TODO: Doesn't seem to work

		child.focus_neighbor_right = restore_defaults_button.get_path() if restore_defaults_button else close_button.get_path()
		child.focus_neighbor_left = focused_sidebar_item.get_path()

	first_child.grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		if controls:
			controls.grab_focus()


func _on_focus_lost() -> void:
	focus_node = focused_sidebar_item

	super()
