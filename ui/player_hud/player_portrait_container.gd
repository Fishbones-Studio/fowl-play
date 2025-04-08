extends CenterContainer
@onready var hurt_duration_timer : Timer = $HurtDuration
@onready var color_rect : ColorRect = $ColorRect

func _ready() -> void:
	SignalManager.player_hurt.connect(
		func(): 
			hurt_duration_timer.start()
			color_rect.show()
	)


func _on_hurt_duration_timeout() -> void:
	color_rect.hide()
