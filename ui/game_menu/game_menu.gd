## Handles navigation between scenes.
extends Node3D


@export var items: Array[Area3D] 

var highlight_scale_factor: float = 1.1 
## Keeps track of the currently selected item.
var current_index: int = 0 
var is_keyboard_navigation_active: bool = false 
## Stores original scales of items to reset after highlight.
var original_scales: Dictionary = {} 
## Tracks which item the mouse is hovering over.
var mouse_hover_index: int = -1 


## Called when the node is added to the scene.
func _ready() -> void:
	if items.is_empty():
		##fetch children that are Area3D
		items = get_children().filter(func(child): return child is Area3D)
	
	for item in items:
		original_scales[item] = item.scale
	
	reset_highlights()


## Handles user input events.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		is_keyboard_navigation_active = false
	
	if event.is_action_pressed("move_left") or event.is_action_pressed("joypad_button_left"):
		activate_keyboard_navigation()
		move_selection(-1)
	elif event.is_action_pressed("move_right") or event.is_action_pressed("joypad_button_right"):
		activate_keyboard_navigation()
		move_selection(1)
	elif event.is_action_pressed("accept"):
		select_current_item()


## Activates keyboard navigation and disables mouse-based selection.
func activate_keyboard_navigation() -> void:
	is_keyboard_navigation_active = true
	mouse_hover_index = -1


## Moves the selection left or right based on direction (-1 for left, 1 for right).
func move_selection(direction: int) -> void:
	if items.is_empty():
		return
	
	current_index = wrapi(current_index + direction, 0, items.size())
	highlight_current_item()


## Resets all item highlights back to their original scale.
func reset_highlights() -> void:
	for item in items:
		if item in original_scales:
			item.scale = original_scales[item]


## Highlights the currently selected item 
func highlight_current_item() -> void:
	reset_highlights()
	
	if items.is_empty():
		return
	
	if is_keyboard_navigation_active or mouse_hover_index == current_index:
		var current_item: Area3D = items[current_index]
		if current_item in original_scales:
			current_item.scale = original_scales[current_item] * highlight_scale_factor


## Handles item selection and triggers the appropriate scene switch.
func select_current_item() -> void:
	if items.is_empty():
		return
	
	var selected_item: Area3D = items[current_index]
	
	match selected_item.name:
		"Flyer":
			SignalManager.emit_throttled("switch_ui_scene", ["uid://xhakfqnxgnrr"])
			SignalManager.emit_throttled("switch_game_scene", ["uid://bhnqi4fnso1hh"])
		"Shop":
			SignalManager.switch_ui_scene.emit("uid://c4pohtsnom3x7")
		"Inventory":
			SignalManager.switch_ui_scene.emit("uid://dvkxcgdk0goul")


## Handles mouse hover highlighting.
func _mouse_hover_highlight(item: Area3D) -> void:
	for i in items.size():
		if items[i] == item:
			mouse_hover_index = i
			if not is_keyboard_navigation_active:
				current_index = i
				highlight_current_item()
			break


## Handles mouse click selection of an item.
func _on_area_input_event(item: Area3D, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_keyboard_navigation_active = false
		for i in items.size():
			if items[i] == item:
				current_index = i
				select_current_item()
				break


## Mouse hover events for specific items.
func _on_inventory_mouse_entered() -> void:
	_mouse_hover_highlight(items[0]) 

func _on_shop_mouse_entered() -> void:
	_mouse_hover_highlight(items[1])  

func _on_flyer_mouse_entered() -> void:
	_mouse_hover_highlight(items[2])
