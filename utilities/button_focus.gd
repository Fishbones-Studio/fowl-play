extends Button

func _ready():
	SignalManager.ui_disabled.connect(_try_grab_focus)
	visibility_changed.connect(_try_grab_focus)
	await get_tree().root.ready
	_try_grab_focus()

func _try_grab_focus():
	if is_inside_tree() and visible:
		grab_focus()
