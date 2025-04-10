# Handles UI input (mouse, keyboard, controller) and emits navigation signals.
extends Node

# signals
signal selection_moved(direction: int) 
signal current_item_selected()          
signal keyboard_navigation_activated()  
signal keyboard_navigation_deactivated() 
signal item_clicked(item_index: int)   

# controller checks, timers
var is_controller_connected: bool = false
var can_move_with_stick: bool = true
var stick_cooldown: float = 0.3
var stick_cooldown_timer: Timer
var controller_was_used: bool = false


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_check_for_controller()
	
	stick_cooldown_timer = Timer.new()
	add_child(stick_cooldown_timer)
	stick_cooldown_timer.one_shot = true
	stick_cooldown_timer.timeout.connect(_on_stick_cooldown_timeout)


func _input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		keyboard_navigation_deactivated.emit()
		controller_was_used = false
	
	if is_controller_connected and event is InputEventJoypadMotion:
		var axis_value = event.axis_value
		var axis = event.axis
		
		if axis == 0 and abs(axis_value) > 0.5:
			if can_move_with_stick:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				var direction = sign(axis_value)
				selection_moved.emit(direction)  
				can_move_with_stick = false
				stick_cooldown_timer.start(stick_cooldown)
				controller_was_used = true
				keyboard_navigation_activated.emit()
	
	elif event.is_action_pressed("move_left"):
		handle_directional_input(-1)
	elif event.is_action_pressed("move_right"):
		handle_directional_input(1)
	elif event.is_action_pressed("joypad_button_left"):
		handle_directional_input(-1)
	elif event.is_action_pressed("joypad_button_right"):
		handle_directional_input(1)
	elif event.is_action_pressed("accept"):
		controller_was_used = true
		current_item_selected.emit() 


func _on_stick_cooldown_timeout() -> void:
	can_move_with_stick = true


func handle_directional_input(direction: int) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	controller_was_used = true
	keyboard_navigation_activated.emit()
	selection_moved.emit(direction)  


func handle_item_click(item: Area3D, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var menu = get_parent()
		if menu and menu.has_method("get_item_index"):
			var index = menu.get_item_index(item)
			item_clicked.emit(index)


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_check_for_controller()


func _check_for_controller() -> void:
	is_controller_connected = Input.get_connected_joypads().size() > 0
