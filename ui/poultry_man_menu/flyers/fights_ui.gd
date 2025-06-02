extends Control

@export var flyers_to_setup: Array[ArenaFlyerResource]

@onready var fights_container: GridContainer = %FightsContainer
@onready var arena_flyer_resource: PackedScene = preload("uid://b68pl3dx4qrx7")
@onready var flyer_preview_container : ArenaFlyerPreviewContainer = %ArenaFlyerPreviewContainer
@onready var size_placeholder: Control = %SizePlaceholder

func _ready() -> void:
	_add_arena_flyers.call_deferred()
	_setup_controller_navigation.call_deferred()
	# Hide preview initially
	flyer_preview_container.hide()
	size_placeholder.show()

func _add_arena_flyers() -> void:
	for flyer_resource in flyers_to_setup:
		var flyer: PanelContainer = arena_flyer_resource.instantiate()
		fights_container.add_child(flyer)
		flyer.setup(flyer_resource)
		# Connect signals for preview logic
		flyer.focused.connect(_on_flyer_focused)
		flyer.hovered.connect(_on_flyer_focused)
		flyer.unhovered.connect(_on_flyer_unhovered)

func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_flyers: Array = []
	for child in fights_container.get_children():
		if child is PanelContainer:
			child.focus_mode = Control.FOCUS_ALL
			focusable_flyers.append(child)

	if focusable_flyers.size() > 0:
		focusable_flyers[0].grab_focus()

func _on_flyer_focused(flyer_resource: ArenaFlyerResource) -> void:
	flyer_preview_container.show()
	size_placeholder.hide()
	flyer_preview_container.setup(flyer_resource)

func _on_flyer_unhovered(_flyer_resource: ArenaFlyerResource) -> void:
	# Hide preview only if no flyer is focused
	await get_tree().process_frame
	var focused: Control = get_viewport().gui_get_focus_owner()
	if not (focused and focused.is_in_group("flyer_item")):
		flyer_preview_container.hide()
		size_placeholder.show()

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_FIGHT_FLYERS)
