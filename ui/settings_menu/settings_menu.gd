extends Control

@onready var content: Control = %Content
@onready var keybinds_menu: PackedScene = load("uid://bkbsjmbi2yaoh")
@onready var controls: Button = %Controls
@onready var settings_label: Label = %SettingsLabel


func _ready() -> void:
	controls.grab_focus()
	SignalManager.settings_menu_toggled.emit(true)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_close_window()


func _on_controls_focus_entered() -> void:
	_clear_content()
	_change_header_label("Controls")


func _on_key_bindings_focus_entered() -> void:
	_clear_content()
	
	var keybinds_menu_instance: Node = keybinds_menu.instantiate()
	content.add_child(keybinds_menu_instance)
	_change_header_label("Key Bindings")


func _on_graphics_focus_entered() -> void:
	_clear_content()
	_change_header_label("Graphics")


func _on_audio_focus_entered() -> void:
	_clear_content()
	_change_header_label("Audio")


func _clear_content() -> void:
	for child in content.get_children():
		content.remove_child(child)


func _on_close_button_button_up() -> void:
	_close_window()


func _change_header_label(name: String) -> void:
	settings_label.text = "Settings / " + name


func _close_window() -> void:
	SignalManager.settings_menu_toggled.emit(false)
	queue_free()
