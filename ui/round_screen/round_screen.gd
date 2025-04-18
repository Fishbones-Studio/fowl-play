extends Control

var display_text: String 

@onready var title: Label = $CenterContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer


func _ready() -> void:
	title.text = display_text
	animation_player.play("fade")
	animation_timer.start()


func setup(params: Dictionary) -> void:
	display_text = params.get("display_text")


func _on_animation_timer_timeout() -> void:
	UIManager.toggle_ui(UIEnums.UI.ROUND_SCREEN)
