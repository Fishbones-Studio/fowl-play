extends Control

@onready var title: Label = $CenterContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer


func _ready() -> void:
	title.text = str("Round ", GameManager.current_round)
	animation_player.play("fade")

	animation_timer.start()


func _on_animation_timer_timeout() -> void:
	queue_free()
