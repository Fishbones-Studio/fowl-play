extends Marker3D

@export_range(0, 100, 1) var spawn_chance: int
@export var hazard_scene: PackedScene


func _ready() -> void:
	_spawn_hazard()


func _spawn_hazard() -> void:
	if randi() % 100 < spawn_chance and hazard_scene:
		var hazard: BaseHazard = hazard_scene.instantiate()
		add_child(hazard)

		hazard.global_position = global_position
