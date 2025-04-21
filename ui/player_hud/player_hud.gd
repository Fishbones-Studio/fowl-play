extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# TODO fix this, triggers way too often and it doesnt work
	
	SignalManager.ui_disabled.connect(
		func(previous_controll : Control):
			if previous_controll is PauseScreen:
				print("Adwwwafw")
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				if !visible:
					SignalManager.switch_ui_scene.emit(UIEnums.UI.PLAYER_HUD)
	)
