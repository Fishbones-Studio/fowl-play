extends Control

var display_text: String
var currency_overview_change: Dictionary

@onready var title_label: Label = %TitleLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer
@onready var currency_overview: CurrencyOverview = %CurrencyOverview


func _ready() -> void:
	title_label.text = display_text
	animation_player.play("fade")
	animation_timer.start()

	currency_overview.update_label_container(currency_overview_change)
	currency_overview.click_label.visible = false


func _input(_event: InputEvent) -> void:
	if visible: get_viewport().set_input_as_handled() # Block all input


func setup(params: Dictionary) -> void:
	display_text = params.get("display_text")
	currency_overview_change = params.get("currency_dict", {})


func _on_animation_timer_timeout() -> void:
	UIManager.remove_ui(self)
