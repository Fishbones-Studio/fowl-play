extends Button


func _ready():
	SignalManager.ui_disabled.connect(_try_grab_focus)
	visibility_changed.connect(_try_grab_focus.bind(self))
	await get_tree().root.ready
	_try_grab_focus(self)


func _try_grab_focus(_previous_ui : Control):
	if is_inside_tree() and visible:
		grab_focus()
