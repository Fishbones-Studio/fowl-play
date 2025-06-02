extends Control

@export var flyers_to_setup: Array[ArenaFlyerResource]

@onready var fights_container: GridContainer = %FightsContainer
@onready var arena_flyer_resource: PackedScene = preload("uid://b68pl3dx4qrx7")

func _ready() -> void:
	_add_arena_flyers.call_deferred()
	_setup_controller_navigation.call_deferred()

func _add_arena_flyers() -> void:
	for flyer_resource in flyers_to_setup:
		var flyer: PanelContainer = arena_flyer_resource.instantiate()
		fights_container.add_child(flyer)
		flyer.setup(flyer_resource)

func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_flyers: Array = []
	for child in fights_container.get_children():
		if child is PanelContainer:
			child.focus_mode = Control.FOCUS_ALL
			focusable_flyers.append(child)

	if focusable_flyers.size() > 0:
		focusable_flyers[0].grab_focus()

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_FIGHT_FLYERS)
