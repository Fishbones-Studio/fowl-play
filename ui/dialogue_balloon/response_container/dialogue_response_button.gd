class_name DialogueResponseButton extends Button

var response_signal : Signal
var response : DialogueResponse :
	set(value):
		text = value.text
		response = value


func _on_pressed() -> void:
	print(response)
	response_signal.emit(response)
