extends Control

const ARENA_FLYER = preload("uid://b68pl3dx4qrx7")

@onready var fights_container : GridContainer = %FightsContainer

@export var flyers_to_setup : Array[ArenaFlyerResource]

func _ready() -> void:
	_add_arena_flyers()
	_setup_controller_navigation()

func _add_arena_flyers() -> void:
	for flyer_resource in flyers_to_setup:
		var flyer = ARENA_FLYER.instantiate()
		fights_container.add_child(flyer)
		flyer.setup(flyer_resource)

func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_flyers: Array = []
	for child in fights_container.get_children():
		if child is PanelContainer:
			child.focus_mode = Control.FOCUS_ALL
			focusable_flyers.append(child)
			print(child)

	if focusable_flyers.size() > 0:
		focusable_flyers[0].grab_focus()

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_FIGHT_FLYERS)
