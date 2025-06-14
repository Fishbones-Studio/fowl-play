class_name UserInterface
extends Control

@export var handle_focus: bool = false
@export var focus_node: Control = null


func _ready() -> void:
	if handle_focus:
		SignalManager.focus_lost.connect(_on_focus_lost)


func _on_focus_lost() -> void:
	print("connecting focus lost")
	if focus_node and UIManager.current_ui == self:
		print("grabbing focus")
		focus_node.grab_focus()
