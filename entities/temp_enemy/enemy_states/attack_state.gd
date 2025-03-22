extends BaseEnemyState

func process(delta: float) -> void:
	SignalManager.hurt_player.emit(1)
