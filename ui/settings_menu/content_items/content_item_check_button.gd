class_name ContentItemCheckButton
extends ContentItem


## Signal emitted when the checkbox state changes.
signal toggled(is_pressed: bool)

@onready var label: Label = %Label
@onready var checkbutton: CheckButton = %CheckButton
@onready var panel: Panel = %Panel


func _ready() -> void:
	# Connect the CheckButton's built-in signal to our handler
	if checkbutton:
		checkbutton.toggled.connect(_on_checkbutton_toggled)


## Sets the text displayed next to the checkbox.
func set_text(text: String) -> void:
	if label:
		label.text = text
	else:
		push_warning("Label node not found. Ensure the Label node is named '%Label'.")


## Sets the current state of the checkbox without emitting the toggled signal.
## Useful for initializing the value.
func set_pressed_no_signal(is_pressed: bool) -> void:
	if checkbutton:
		checkbutton.set_pressed_no_signal(is_pressed)


## Sets the current state of the checkbox and emits the toggled signal.
func set_pressed(is_pressed: bool) -> void:
	if checkbutton:
		checkbutton.button_pressed = is_pressed


## Returns the current state of the checkbox.
func is_pressed() -> bool:
	if checkbutton:
		return checkbutton.button_pressed
	return false


## Internal handler for when the CheckButton's state changes.
func _on_checkbutton_toggled(is_pressed: bool) -> void:
	# Emit our custom signal
	toggled.emit(is_pressed)


func _on_focus_entered() -> void:
	checkbutton.grab_focus()


func _on_check_button_focus_entered() -> void:
	_set_neighbors_for(checkbutton)
	_toggle_active(panel, true)


func _on_check_button_focus_exited() -> void:
	_toggle_active(panel, false)
