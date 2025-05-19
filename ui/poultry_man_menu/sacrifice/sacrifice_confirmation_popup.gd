extends Control

const FOR_LABEL_TEMPLATE_TEXT : String = "This will award %d Feathers Of Rebirth"

var _rounds_won_this_run: int

@onready var for_label : Label = %FORLabel

func _ready() -> void:
	_rounds_won_this_run = SaveManager.get_loaded_rounds_won()
	for_label.text = FOR_LABEL_TEMPLATE_TEXT % _rounds_won_this_run

func _cancel() -> void:
	UIManager.remove_ui(self)


func _on_close_button_pressed() -> void:
	_cancel()


func _on_confirm_pressed() -> void:
	if _rounds_won_this_run > 0:
		GameManager.feathers_of_rebirth += _rounds_won_this_run

	GameManager.reset_game()
	_cancel()


func _on_cancel_pressed() -> void:
	_cancel()
