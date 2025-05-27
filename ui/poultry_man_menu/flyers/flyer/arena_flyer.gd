extends PanelContainer

@export var scene_to_load : SceneEnums.Scenes

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")

@onready var arena_label : Label = %ArenaLabel
@onready var arena_icon : TextureRect = %ArenaIcon

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)

func setup(flyer_resource : ArenaFlyerResource):
	scene_to_load = flyer_resource.scene_to_load
	arena_icon.texture = flyer_resource.arena_icon
	
	arena_label.text = SceneEnums.scene_to_string(scene_to_load)

func _trigger_scene_load() -> void:
	UIManager.load_game_with_loading_screen(scene_to_load)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_trigger_scene_load()
	elif event.is_action_pressed("ui_accept") and has_focus():
		_trigger_scene_load()

func _on_focus_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)

func _on_focus_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)

func _on_mouse_entered() -> void:
	grab_focus()

func _on_mouse_exited() -> void:
	_on_focus_exited()
