extends HBoxContainer

@onready var chicken_stats_container : ChickenStatsContainer = $ChickenStatsContainer


func _ready() -> void:
	_update_bonus_stats()
	visibility_changed.connect(
		func():
			if visible:
				_update_bonus_stats()
	)


func _update_bonus_stats() -> void:
	for stat_container : StatContainer in chicken_stats_container.stat_containers:
		stat_container.update_from_stats(GameManager.chicken_player.stats)
