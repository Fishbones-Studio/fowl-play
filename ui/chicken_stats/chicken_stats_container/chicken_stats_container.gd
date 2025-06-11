class_name ChickenStatsContainer
extends VBoxContainer

@onready var stat_containers: Array[StatContainer]

func _ready() -> void:
	stat_containers = []
	for child in get_children():
		if child is StatContainer:
			stat_containers.append(child)
