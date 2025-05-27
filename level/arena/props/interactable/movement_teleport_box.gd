extends InteractBox

@onready var player_teleport_position : Marker3D = $PlayerTeleportMarker

func interact() -> void:
	GameManager.chicken_player.global_position = player_teleport_position.global_position
