extends Control

@export var victory_lines: Array[String] = [
	"The Weak Perish, You Endure.",
	"The Arena Bows",
	"Bloody Triumph!",
	"Coop de Grâce!",
]

var is_transitioning: bool = false
var currency_overview_change : Dictionary

@onready var victory_label: Label = $MarginContainer/VBoxContainer/VictoryLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var victory_music_player : AudioStreamPlayer = $VictoryMusicPlayer
@onready var currency_overview : CurrencyOverview = %CurrencyOverview


func _ready() -> void:
	victory_label.text = victory_lines.pick_random()
	get_tree().paused = true
	victory_music_player.play()
	animation_player.play("fade")
	currency_overview.update_label_container(currency_overview_change)


func _input(event: InputEvent) -> void:
	if (((event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT) or event.is_action_pressed("ui_accept"))
		and not animation_player.is_playing()
		and not is_transitioning
	):
		_return_to_game_menu()
		return

	get_viewport().set_input_as_handled()


func _return_to_game_menu() -> void:
	victory_music_player.stop()
	is_transitioning = true
	animation_player.play("RESET")

	get_tree().paused = false
	UIManager.remove_ui(self)
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU, UIEnums.UI.NULL)


func setup(params: Dictionary) -> void:
	currency_overview_change = params.get("currency_dict", {})
