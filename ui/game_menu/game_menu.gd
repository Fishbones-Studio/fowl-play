## Handles navigation between scenes.
extends Node3D


@export var items: Array[Area3D]
@export var flicker_light: SpotLight3D 
@export var flicker_timer: Timer      

var highlight_scale_factor: float = 1.1 
var highlight_color: Color = Color.YELLOW
## Keeps track of the currently selected item.
var current_index: int = 0 
var is_keyboard_navigation_active: bool = false 
## Stores original scales of items to reset after highlight.
var original_scales: Dictionary = {}
## Stores original colors of labels
var original_label_colors: Dictionary = {}
## Tracks which item the mouse is hovering over.
var mouse_hover_index: int = -1 
var is_flickering: bool = false



## Called when the node is added to the scene.
func _ready() -> void:
	if items.is_empty():
		##fetch children that are Area3D
		items = get_children().filter(func(child): return child is Area3D)
	
	for item in items:
		original_scales[item] = item.scale
		var label = find_label_in_item(item)
		if label:
			original_label_colors[item] = label.modulate
	
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.wait_time = 2
	flicker_timer.start()
	
	reset_highlights()


func _on_flicker_timer_timeout():
	if not is_flickering and flicker_light:
		start_flicker_effect()

		flicker_timer.wait_time = randf_range(3, 10)
		flicker_timer.start()


func start_flicker_effect():
	is_flickering = true
	var original_energy = flicker_light.light_energy
	
	# Create flicker pattern
	var tween = create_tween().set_parallel(false)
	
	# Random flicker sequence
	tween.tween_property(flicker_light, "light_energy", randf_range(0.1, original_energy*0.3), 0.05)
	tween.tween_property(flicker_light, "light_energy", randf_range(original_energy*0.8, original_energy*1.2), 0.1)
	tween.tween_property(flicker_light, "light_energy", randf_range(0.2, original_energy*0.5), 0.07)
	tween.tween_property(flicker_light, "light_energy", original_energy, 0.3)
	
	tween.tween_callback(func(): is_flickering = false)


func find_label_in_item(item: Node) -> Label3D:
	for child in item.get_children():
		if child is Label3D:
			return child
		# Recursively check children if needed
		var found = find_label_in_item(child)
		if found:
			return found
	return null

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
		if item in original_label_colors:
			var label = find_label_in_item(item)
			if label:
				label.modulate = original_label_colors[item]


## Highlights the currently selected item 
func highlight_current_item() -> void:
	reset_highlights()
	
	if items.is_empty():
		return
	
	if is_keyboard_navigation_active or mouse_hover_index == current_index:
		var current_item: Area3D = items[current_index]
		if current_item in original_scales:
			current_item.scale = original_scales[current_item] * highlight_scale_factor
		
		# Highlight the label color
		var label = find_label_in_item(current_item)
		if label and current_item in original_label_colors:
			label.modulate = highlight_color


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

func _on_inventory_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	_handle_item_click(items[0], event)

func _on_shop_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	_handle_item_click(items[1], event)

func _on_flyer_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	_handle_item_click(items[2], event)

func _handle_item_click(item: Area3D, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_keyboard_navigation_active = false
		current_index = items.find(item)
		select_current_item()

## Mouse hover events for specific items.
func _on_inventory_mouse_entered() -> void:
	_mouse_hover_highlight(items[0]) 

func _on_shop_mouse_entered() -> void:
	_mouse_hover_highlight(items[1])  

func _on_flyer_mouse_entered() -> void:
	_mouse_hover_highlight(items[2])
