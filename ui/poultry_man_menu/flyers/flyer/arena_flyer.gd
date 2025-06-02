extends PanelContainer

signal hovered(item)
signal unhovered(item)
signal focused(item)

@export var scene_to_load: SceneEnums.Scenes

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")
var flyer_resource: ArenaFlyerResource

@onready var arena_label: Label = %ArenaLabel
@onready var arena_icon: TextureRect = %ArenaIcon

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	add_theme_stylebox_override("panel", normal_stylebox)

func setup(_flyer_resource: ArenaFlyerResource) -> void:
	flyer_resource = _flyer_resource
	scene_to_load = flyer_resource.scene_to_load
	arena_icon.texture = flyer_resource.icon
	arena_label.text = flyer_resource.title

func _trigger_scene_load() -> void:
	await get_tree().process_frame
	UIManager.load_game_with_loading_screen(
		scene_to_load,
		UIEnums.UI.PLAYER_HUD,
		{},
		{
			"enemies": flyer_resource.get_combined_enemy_scenes(),
			"max_rounds": flyer_resource.rounds
		}
	)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_trigger_scene_load()
	elif event.is_action_pressed("ui_accept") and has_focus():
		_trigger_scene_load()

func _on_focus_entered() -> void:
	add_theme_stylebox_override("panel", hover_stylebox)
	focused.emit(flyer_resource)

func _on_focus_exited() -> void:
	add_theme_stylebox_override("panel", normal_stylebox)
	unhovered.emit(flyer_resource)

func _on_mouse_entered() -> void:
	grab_focus()
	hovered.emit(flyer_resource)

func _on_mouse_exited() -> void:
	_on_focus_exited()
	unhovered.emit(flyer_resource)
