extends Control

@export var death_lines: Array[String] = [
	"Your Feathers Line the Arena Floor.",
	"The Pecking Order Claims Another.",
	"Plucked. Beheaded. Devoured.",
	"Clucked Your Last Cluck.",
	"Your Egg Was Doomed From the Start.",
	"No One Remembers the Fallen Hens.",
	"You Died.",
	"Mortuus Es Ut Scortum.",
	"Your Must Be Proud.",
]

var is_transitioning: bool = false

@onready var title_label: Label = %TitleLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var currency_overview : CurrencyOverview = %CurrencyOverview


func _ready() -> void:
	title_label.text = death_lines.pick_random()
	get_tree().paused = true

	# Resetting the game and calculating the difference in prosperity eggs
	var pre_reset_pe = GameManager.prosperity_eggs
	GameManager.reset_game()
	var pe_diff = GameManager.prosperity_eggs - pre_reset_pe
	var currency_overview_dict : Dictionary[CurrencyEnums.CurrencyTypes, int] = {
			CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS: pe_diff,
		}
	animation_player.play("fade_to_black")
	currency_overview.label.text = "Lost" # I'm lazy.
	currency_overview.update_label_container(currency_overview_dict)


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
	is_transitioning = true
	animation_player.play("fade_to_white")

	get_tree().paused = false
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	
	UIManager.remove_ui(self)
