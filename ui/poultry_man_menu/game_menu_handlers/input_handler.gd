# Handles UI input (mouse, keyboard, controller) and emits navigation signals.
extends Node

signal selection_moved(direction: int)
signal current_item_selected()
# signals for vertical navigation
signal navigate_up_pressed()
signal navigate_down_pressed()
signal keyboard_navigation_activated()
signal keyboard_navigation_deactivated()

const STICK_THRESHOLD: float = 0.5
const STICK_COOLDOWN_TIME: float = 0.3
const HORIZONTAL_AXIS: int = 0
# the vertical axis for the controller stick
const VERTICAL_AXIS: int = 1

# controller checks, timers
var is_controller_connected: bool = false
var can_move_with_stick: bool = true
var controller_was_used: bool = false
var stick_cooldown_timer: Timer

var directional_actions: Array[StringName] = [
	&"ui_left",
	&"ui_right",
	&"joypad_button_left",
	&"joypad_button_right",
]

var action_directions: Dictionary[StringName, int] = {
	&"ui_left": 1,
	&"ui_right": -1,
	&"joypad_button_left": 1,
	&"joypad_button_right": -1,
}


func _ready() -> void:
	_setup_controller_detection()
	_setup_stick_cooldown_timer()


func _input(event: InputEvent) -> void:
	if UIManager.game_input_blocked:
		return

	_handle_input_event(event)


func _setup_controller_detection() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_controller_status()


func _setup_stick_cooldown_timer() -> void:
	stick_cooldown_timer = Timer.new()
	add_child(stick_cooldown_timer)
	stick_cooldown_timer.one_shot = true
	stick_cooldown_timer.timeout.connect(_on_stick_cooldown_timeout)


func _handle_input_event(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion()
	elif event is InputEventJoypadMotion and is_controller_connected:
		_handle_joypad_motion(event)
	elif _is_directional_action_pressed(event):
		var direction: int = _get_direction_from_event(event)
		_handle_directional_input(direction)
	# Checks for ui_up and ui_down
	elif event.is_action_pressed(&"ui_up"):
		_handle_vertical_input(true) # true for up
	elif event.is_action_pressed(&"ui_down"):
		_handle_vertical_input(false) # false for down
	elif event.is_action_pressed(&"ui_accept"):
		_handle_accept_input()


func _handle_mouse_motion() -> void:
	_set_mouse_mode_visible()
	_deactivate_keyboard_navigation()


func _handle_joypad_motion(event: InputEventJoypadMotion) -> void:
	# handle both horizontal and vertical stick movement
	if not can_move_with_stick or abs(event.axis_value) < STICK_THRESHOLD:
		return

	if event.axis == HORIZONTAL_AXIS:
		var direction: int = -sign(event.axis_value)
		_handle_controller_navigation(direction)
	elif event.axis == VERTICAL_AXIS:
		var is_up: bool = event.axis_value < 0
		_handle_vertical_input(is_up)
		_start_stick_cooldown()


func _handle_controller_navigation(direction: int) -> void:
	_set_mouse_mode_hidden()
	_activate_controller_usage()
	_activate_keyboard_navigation()
	_emit_selection_moved(direction)
	_start_stick_cooldown()


func _is_directional_action_pressed(event: InputEvent) -> bool:
	for action in directional_actions:
		if event.is_action_pressed(action):
			return true
	return false


func _get_direction_from_event(event: InputEvent) -> int:
	for action in directional_actions:
		if event.is_action_pressed(action):
			return action_directions[action]
	return 0


func _handle_directional_input(direction: int) -> void:
	_set_mouse_mode_hidden()
	_activate_controller_usage()
	_activate_keyboard_navigation()
	_emit_selection_moved(direction)


# function to handle vertical input
func _handle_vertical_input(is_up: bool) -> void:
	_set_mouse_mode_hidden()
	_activate_controller_usage()
	_activate_keyboard_navigation()
	if is_up:
		navigate_up_pressed.emit()
	else:
		navigate_down_pressed.emit()


func _handle_accept_input() -> void:
	_activate_controller_usage()
	current_item_selected.emit()


func _emit_selection_moved(direction: int) -> void:
	selection_moved.emit(direction)


func _start_stick_cooldown() -> void:
	can_move_with_stick = false
	stick_cooldown_timer.start(STICK_COOLDOWN_TIME)


func _on_stick_cooldown_timeout() -> void:
	can_move_with_stick = true


func _set_mouse_mode_visible() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	controller_was_used = false


func _set_mouse_mode_hidden() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _activate_controller_usage() -> void:
	controller_was_used = true


func _activate_keyboard_navigation() -> void:
	keyboard_navigation_activated.emit()


func _deactivate_keyboard_navigation() -> void:
	keyboard_navigation_deactivated.emit()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_controller_status()


func _update_controller_status() -> void:
	is_controller_connected = Input.get_connected_joypads().size() > 0
