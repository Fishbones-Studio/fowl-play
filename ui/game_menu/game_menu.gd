extends Node3D

@export var items: Array[Area3D]
@export var input_handler: Node
@export var light_handler: Node

# Highlight variables
var highlight_scale_factor: float = 1.1
var highlight_color: Color = Color.YELLOW

# Index variables
var current_index: int = 0
var is_keyboard_navigation_active: bool = false
var original_scales: Dictionary = {}
var original_label_colors: Dictionary = {}
var mouse_hover_index: int = -1

func _ready():
	if items.is_empty():
		items = get_children().filter(func(child): return child is Area3D)
	
	# Store original states
	for i in items.size():
		var item = items[i]
		original_scales[item] = item.scale
		var label = find_label_in_item(item)
		if label:
			original_label_colors[item] = label.modulate
		
		# Connect signals
		item.input_event.connect(_on_item_input_event.bind(i))
		item.mouse_entered.connect(_on_item_mouse_entered.bind(i))
		item.mouse_exited.connect(_on_item_mouse_exited.bind(i))
	
	# Connect input handler signals
	if input_handler:
		input_handler.move_selection.connect(_on_move_selection)
		input_handler.select_current_item.connect(_on_select_current_item)
		input_handler.keyboard_navigation_activated.connect(_on_keyboard_navigation_activated)
		input_handler.keyboard_navigation_deactivated.connect(_on_keyboard_navigation_deactivated)
		input_handler.item_clicked.connect(_on_item_clicked_with_index)
	
	reset_highlights()

func get_item_index(item: Area3D) -> int:
	return items.find(item)

func _on_item_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int, item_index: int):
	input_handler.handle_item_click(items[item_index], event)
	
	if event is InputEventMouseMotion:
		_mouse_hover_highlight(items[item_index])

func _on_item_clicked_with_index(index: int):
	if index >= 0 and index < items.size():
		current_index = index
		is_keyboard_navigation_active = false
		highlight_current_item()
		_on_select_current_item()

func _on_item_mouse_entered(item_index: int):
	_mouse_hover_highlight(items[item_index])

func _on_item_mouse_exited(item_index: int):
	_check_mouse_exit(items[item_index])

func find_label_in_item(item: Node) -> Label3D:
	for child in item.get_children():
		if child is Label3D:
			return child
		var found = find_label_in_item(child)
		if found:
			return found
	return null

func _on_move_selection(direction: int):
	if items.is_empty():
		return
	
	# Clear mouse hover state and activate keyboard navigation
	mouse_hover_index = -1
	is_keyboard_navigation_active = true
	
	current_index = wrapi(current_index + direction, 0, items.size())
	highlight_current_item()

func _on_select_current_item():
	if items.is_empty():
		return
	
	var selected_item = items[current_index]
	match selected_item.name:
		"Flyer":
			SignalManager.emit_throttled("switch_ui_scene", ["uid://xhakfqnxgnrr"])
			SignalManager.emit_throttled("switch_game_scene", ["uid://bhnqi4fnso1hh"])
		"Shop":
			SignalManager.switch_ui_scene.emit("uid://c4pohtsnom3x7")
		"Inventory":
			SignalManager.switch_ui_scene.emit("uid://dvkxcgdk0goul")

func _on_keyboard_navigation_activated():
	is_keyboard_navigation_active = true
	mouse_hover_index = -1
	highlight_current_item()

func _on_keyboard_navigation_deactivated():
	is_keyboard_navigation_active = false
	mouse_hover_index = -1
	reset_highlights()

func reset_highlights():
	for item in items:
		if item in original_scales:
			item.scale = original_scales[item]
		if item in original_label_colors:
			var label = find_label_in_item(item)
			if label:
				label.modulate = original_label_colors[item]

func highlight_current_item():
	reset_highlights()
	if items.is_empty():
		return
	
	var current_item = items[current_index]
	if current_item in original_scales:
		current_item.scale = original_scales[current_item] * highlight_scale_factor
	
	var label = find_label_in_item(current_item)
	if label and current_item in original_label_colors:
		label.modulate = highlight_color

func _mouse_hover_highlight(item: Area3D):
	if is_keyboard_navigation_active:
		return
	
	var found_index = items.find(item)
	if found_index != -1:
		mouse_hover_index = found_index
		current_index = found_index
		reset_highlights()
		item.scale = original_scales[item] * highlight_scale_factor
		var label = find_label_in_item(item)
		if label:
			label.modulate = highlight_color

func _check_mouse_exit(item: Area3D):
	if mouse_hover_index != -1 and items[mouse_hover_index] == item:
		mouse_hover_index = -1
		if not is_keyboard_navigation_active:
			reset_highlights()
