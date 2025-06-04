class_name Arenas
extends Control

@export var flyers_to_setup: Array[ArenaFlyerResource]

@onready var fights_container: GridContainer = %FightsContainer
@onready var arena_flyer_resource: PackedScene = preload("uid://b68pl3dx4qrx7")
@onready var flyer_preview_container: ArenaFlyerPreviewContainer = %ArenaFlyerPreviewContainer


func _ready() -> void:
	_add_arena_flyers()
	_setup_controller_navigation()
	# Hide preview initially
	flyer_preview_container.hide()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()
		get_viewport().set_input_as_handled()


func _add_arena_flyers() -> void:
	for flyer_resource in flyers_to_setup:
		var flyer: PanelContainer = arena_flyer_resource.instantiate()
		fights_container.add_child(flyer)
		flyer.setup(flyer_resource)

		# Add to group for easier identification
		flyer.add_to_group("flyer_item")

		# Connect signals
		flyer.focused.connect(_on_flyer_focused)
		flyer.hovered.connect(_on_flyer_focused) # Show preview on hover too
		flyer.unhovered.connect(_on_flyer_unhovered)


func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_flyers: Array = fights_container.get_children()

	# Set up focus neighbors for better controller navigation
	_setup_focus_neighbors(focusable_flyers)


func _setup_focus_neighbors(flyers: Array) -> void:
	if flyers.size() <= 1:
		return

	var columns = fights_container.columns if fights_container.columns > 0 else 3

	for i in range(flyers.size()):
		var current_flyer = flyers[i]

		# Left neighbor
		if i % columns > 0:
			current_flyer.focus_neighbor_left = flyers[i - 1].get_path()

		# Right neighbor
		if i % columns < columns - 1 and i + 1 < flyers.size():
			current_flyer.focus_neighbor_right = flyers[i + 1].get_path()

		# Up neighbor
		if i >= columns:
			current_flyer.focus_neighbor_top = flyers[i - columns].get_path()

		# Down neighbor
		if i + columns < flyers.size():
			current_flyer.focus_neighbor_bottom = flyers[i + columns].get_path()


func _on_flyer_focused(flyer_resource: ArenaFlyerResource) -> void:
	flyer_preview_container.show()
	flyer_preview_container.setup(flyer_resource)


func _on_flyer_unhovered(_flyer_resource: ArenaFlyerResource) -> void:
	# Hide preview only if no flyer is focused
	await get_tree().process_frame

	var focused: Control = get_viewport().gui_get_focus_owner()
	if not (focused and focused.is_in_group("flyer_item")):
		flyer_preview_container.hide()


func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.ARENAS)


func _on_visibility_changed() -> void:
	if not visible: return
	if not fights_container: return

	var children: Array = fights_container.get_children()
	if children.is_empty(): return
	children[0].grab_focus()
