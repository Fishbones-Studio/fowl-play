class_name ResponseContainer extends MarginContainer

var response_text : String:
	set(value):
		if response_button:
			response_text = value
			print("Set response to: " + response_text)

@onready var response_button : Button = $CenterContainer/ResponseButton

func update_button_text(text_value: String) -> void:
	if !response_button: return
	if response_text:
		response_button.text = response_text
	else:
		response_text = text_value
		update_button_text(text_value)
