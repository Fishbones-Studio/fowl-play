extends Control

var is_transitioning: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title: Label = $VBoxContainer/TitleLabel
@onready var currency_overview : CurrencyOverview = %CurrencyOverview


func _ready() -> void:
	get_tree().paused = true
	
	# Resetting the game and calculating the difference in prosperity eggs
	var pre_reset_pe = GameManager.prosperity_eggs
	GameManager.reset_game()
	var pe_diff = GameManager.prosperity_eggs - pre_reset_pe
	var currency_overview_change : CurrencyOverviewDict = CurrencyOverviewDict.new({
		"Prosperity Eggs": pe_diff,
	})
	
	animation_player.play("fade_to_black")
	currency_overview.label_amount_dictionary = currency_overview_change
	currency_overview.update_label_container()


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
