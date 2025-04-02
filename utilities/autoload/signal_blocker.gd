# InputBlocker.gd (autoload)
extends Node

var blocked := false:
	set(value):
		blocked = value
		get_tree().root.set_process_input(!value)  
		if value:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  
