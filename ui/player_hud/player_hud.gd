class_name PlayerHud extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	SignalManager.ui_disabled.connect(
		func(previous_controll : Control):
			if previous_controll is PauseScreen or previous_controll is PauseScreen:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				if !visible:
					print("turning player hud visible")
					visible = true
			else:
				print("Previous controll: " + str(previous_controll))
	)
