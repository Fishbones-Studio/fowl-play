class_name UserInterface
extends Control

@export var handle_focus: bool = false
@export var focus_node: Control = null


func _ready() -> void:
	if handle_focus:
		SignalManager.focus_lost.connect(_on_focus_lost)


func _on_focus_lost() -> void:
	if focus_node and UIManager.current_ui == self:
		focus_node.grab_focus()
