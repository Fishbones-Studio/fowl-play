extends Enemy


func _process(delta: float) -> void:
	SignalManager.boss_stats_changed.emit(stats)
