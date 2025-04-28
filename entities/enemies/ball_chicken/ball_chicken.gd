extends Enemy

func _ready() -> void:
	super()	
	SignalManager.boss_name_changed.emit("Ball Chicken")

func _process(delta: float) -> void:
	SignalManager.boss_stats_changed.emit(stats)
