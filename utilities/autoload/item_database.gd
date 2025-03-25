extends BaseDatabase


func _load_resources() -> void:
	_load_items("res://resources/melee_weapons/")
	_load_items("res://resources/ranged_weapons/")
	_load_items("res://resources/passives/")
	_load_items("res://resources/abilities/")
