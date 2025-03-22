extends Control


func _ready() -> void:
	pass

func close_ui():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	get_tree().paused = false
	queue_free()  

func _on_exit_button_pressed():
	close_ui()
	
