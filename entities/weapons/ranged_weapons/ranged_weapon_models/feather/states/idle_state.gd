extends RangedIdleState

@onready var feather_model: Node3D = $"../../feather"

func enter(_previous_state, _information: Dictionary = {}) -> void:
	feather_model.visible = true
