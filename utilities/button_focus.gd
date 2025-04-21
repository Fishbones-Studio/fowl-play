## Simple script to call grab_focus, adds keyboard and controller support to menu's
extends Button

func _ready():
	if is_inside_tree() && self.visible:
		grab_focus()
	SignalManager.ui_disabled.connect(func():
		print("Left tree, grabbing focus")
		if is_inside_tree() && self.visible:
			grab_focus()
		else:
			print("Button not inside tree or visible, not grabbing focus")
	)
