extends BleedHazard

@export var alive_time : float = 3.0

@onready var remove_timer : Timer = $RemoveTimer

func _ready() -> void:
	remove_timer.start(alive_time)


func _on_remove_timer_timeout():
	erase_invalid_bodies()
	queue_free()
