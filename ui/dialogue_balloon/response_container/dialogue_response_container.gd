class_name DialogueResponseContainer extends PanelContainer

@onready var response_button : DialogueResponseButton = $MarginContainer/DialogueResponseButton

func setup_response_button(response: DialogueResponse, press_signal : Signal) -> void:
	if !response_button: 
		push_error("No dialogue response button")
		return
	response_button.response_signal = press_signal
	response_button.response = response

func _on_focus_entered():
	# Forward focus to the button for highlight
	if response_button:
		response_button.grab_focus()
