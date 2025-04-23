# NextEnemy box, fo starting the next round
extends InteractableBox

func interact() -> void:
	SignalManager.start_next_round.emit()
