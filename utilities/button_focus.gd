## Simple script to call grab_focus, adds keyboard and controller support to menu's
extends Button

func _ready():
	if is_inside_tree():
		grab_focus()
	SignalManager.left_tree.connect(func():
		if is_inside_tree():
			grab_focus()
	)
