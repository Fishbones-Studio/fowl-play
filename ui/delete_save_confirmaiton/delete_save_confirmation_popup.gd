extends Control

@onready var cancel_button : Button = %Cancel

func _ready() -> void:
	cancel_button.grab_focus()

func _on_close_button_pressed() -> void:
	UIManager.remove_ui(self)


func _on_confirm_pressed() -> void:
	GameManager.hard_reset_game()
	_on_close_button_pressed()


func _on_cancel_pressed() -> void:
	_on_close_button_pressed()
