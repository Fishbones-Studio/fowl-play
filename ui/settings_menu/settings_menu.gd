extends Control

@onready var content: Control = %Content
@onready var keybinds_menu: PackedScene = load("uid://bkbsjmbi2yaoh")
@onready var controls: Button = %Controls

func _ready() -> void:
	controls.grab_focus()


func _on_controls_focus_entered() -> void:
	_clear_content()


func _on_key_bindings_focus_entered() -> void:
	_clear_content()
	
	var keybinds_menu_instance: Node = keybinds_menu.instantiate()
	content.add_child(keybinds_menu_instance)


func _on_graphics_focus_entered() -> void:
	_clear_content()


func _on_audio_focus_entered() -> void:
	_clear_content()


func _clear_content() -> void:
	for child in content.get_children():
		content.remove_child(child)
