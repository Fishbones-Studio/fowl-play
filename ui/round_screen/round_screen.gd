extends Control

var display_text: String
var currency_overview_change : CurrencyOverviewDict

@onready var title: Label = $VboxContainer/TitleLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer
@onready var currency_overview : CurrencyOverview = %CurrencyOverview


func _ready() -> void:
	title.text = display_text
	animation_player.play("fade")
	animation_timer.start()
	print(currency_overview_change.currency_dict)
	currency_overview.label_amount_dictionary = currency_overview_change
	currency_overview.update_label_container()


func _input(_event: InputEvent) -> void:
	if visible: get_viewport().set_input_as_handled() # Block all input


func setup(params: Dictionary) -> void:
	display_text = params.get("display_text")
	currency_overview_change = params.get("currency_dict", CurrencyOverviewDict.new({}))


func _on_animation_timer_timeout() -> void:
	UIManager.remove_ui(self)
	# Since remove_ui will trigger mouse_mode_visible, explicitly set captured here
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
