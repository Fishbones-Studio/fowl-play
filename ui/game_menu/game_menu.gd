extends Node3D

# Exported Variables
@export var input_handler: Node
@export var light_handler: Node

# Navigation State
var current_index: int = 0
var is_keyboard_navigation_active: bool = false
var is_mouse_hovering: bool = false
var focusable_items: Array[Focusable3D] = []

@onready var flyer_item: Focusable3D = $MenuItems/Flyer  
@onready var shop_item: Focusable3D = $MenuItems/Shop
@onready var inventory_item: Focusable3D = $MenuItems/Inventory

func _ready() -> void:
	# Get all focusable items 
	focusable_items = _get_focusable_items()
	
	# Connect signals for each item
	for i in focusable_items.size():
		var item = focusable_items[i]
		item.focused.connect(_on_item_focused.bind(i))
		item.unfocused.connect(_on_item_unfocused.bind(i))
		item.pressed.connect(_on_item_pressed.bind(i))
	
	# Connect input handler signals
	if input_handler:
		input_handler.selection_moved.connect(_on_move_selection) 
		input_handler.current_item_selected.connect(_on_select_current_item)  
		input_handler.keyboard_navigation_activated.connect(_on_keyboard_navigation_activated)
		input_handler.keyboard_navigation_deactivated.connect(_on_keyboard_navigation_deactivated)
	
	reset_highlights()

func _get_focusable_items() -> Array[Focusable3D]:
	var items: Array[Focusable3D] = []
	var all_nodes = get_tree().get_nodes_in_group("focusable_items")
	for node in all_nodes:
		if node is Focusable3D:
			items.append(node)
	
	# Fallback if no groups are used
	if items.is_empty():
		items = _find_focusable_children(self)
	
	return items

func _find_focusable_children(node: Node) -> Array[Focusable3D]:
	var result: Array[Focusable3D] = []
	for child in node.get_children():
		if child is Focusable3D:
			result.append(child)
		result.append_array(_find_focusable_children(child))
	return result

func _on_item_focused(index: int) -> void:
	is_mouse_hovering = true
	current_index = index

func _on_item_unfocused(index: int) -> void:
	is_mouse_hovering = false
	if not is_keyboard_navigation_active:
		reset_highlights()
	else:
		highlight_current_item()

func _on_item_pressed(index: int) -> void:
	current_index = index
	is_keyboard_navigation_active = false
	highlight_current_item()
	_on_select_current_item()

func _on_move_selection(direction: int) -> void:
	if focusable_items.is_empty():
		return
	
	# Clear mouse hover state and activate keyboard navigation
	is_mouse_hovering = false
	is_keyboard_navigation_active = true
	
	current_index = wrapi(current_index + direction, 0, focusable_items.size())
	highlight_current_item()

func _on_select_current_item() -> void:
	if focusable_items.is_empty():
		return
	
	var selected_item = focusable_items[current_index]
	if selected_item == flyer_item:
		SignalManager.emit_throttled("switch_ui_scene", ["uid://xhakfqnxgnrr"])
		SignalManager.emit_throttled("add_ui_scene", ["uid://dnq3em8w064n4"])
		SignalManager.emit_throttled("switch_game_scene", ["uid://bhnqi4fnso1hh"])
	elif selected_item == shop_item:
		SignalManager.switch_ui_scene.emit("uid://bir1j5qouane0")
	elif selected_item == inventory_item:
		SignalManager.switch_ui_scene.emit("uid://dvkxcgdk0goul")

func _on_keyboard_navigation_activated() -> void:
	is_keyboard_navigation_active = true
	is_mouse_hovering = false
	highlight_current_item()

func _on_keyboard_navigation_deactivated() -> void:
	is_keyboard_navigation_active = false
	reset_highlights()

func reset_highlights() -> void:
	# Only reset if not hovering and not in keyboard navigation
	if is_mouse_hovering or is_keyboard_navigation_active:
		return
	
	_unfocus_all_items()

func highlight_current_item() -> void:
	_unfocus_all_items()
	
	# Then apply highlight to current item if keyboard navigation is active
	if is_keyboard_navigation_active and not focusable_items.is_empty():
		focusable_items[current_index].focus()

func _unfocus_all_items() -> void:
	for item in focusable_items:
		item.unfocus()
