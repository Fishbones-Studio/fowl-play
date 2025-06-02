extends Node3D

@onready var round_handler : RoundHandler = %RoundHandler

func setup(params : Dictionary) -> void:
	if not round_handler:
		push_error("No round handler found")
		return
		
	var enemies: Array[PackedScene] = params.get("enemies", [])
	var max_rounds: int = params.get("max_rounds", 5)
	if enemies.is_empty():
		push_error("No enemies provided for round setup")
		return
	if max_rounds <= 0:
		push_error("Invalid max_rounds value: %d" % max_rounds)
		return
		
	print("Setting up rounds with %d enemies and max %d rounds" % [enemies.size(), max_rounds])
	round_handler.setup_rounds(enemies, max_rounds)
