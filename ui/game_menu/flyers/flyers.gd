extends Control


func _on_exit_button_pressed() -> void:
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
