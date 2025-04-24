class_name StatContainer
extends HBoxContainer

@export var stat: StatsEnums.Stats

@onready var stat_label: Label = $StatLabel
@onready var stat_value_label: Label = $StatValueLabel


func _ready() -> void:
	if stat == null:
		push_error("No stat set for stat container: ", self.name)
		return

	var stat_name: String = StatsEnums.stat_to_string(stat)
	var stat_value: float = GameManager.chicken_player.stats.get(stat_name)

	stat_label.text = stat_name.capitalize()
	stat_value_label.text = str(stat_value) if stat_value else ""
