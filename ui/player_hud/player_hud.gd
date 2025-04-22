class_name PlayerHud extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	visibility_changed.connect(
		func():
			if visible: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
