## This container displays a single stat, including its base value and any changes.
class_name StatContainer
extends HBoxContainer

@export var stat: StatsEnums.Stats

@onready var stat_label: Label = $StatLabel
@onready var base_stat_value_label: Label = $BaseStatValueLabel
@onready var change_stat_value_label: Label = $ChangeStatValueLabel

var _base_value: float = 0.0

func _ready() -> void:
	if not _is_stat_valid():
		return
	
	var stat_name: String = StatsEnums.stat_to_string(stat)
	setup(SaveManager.get_loaded_player_stats().get(stat_name))
	stat_label.text = stat_name.capitalize()

## Initializes the container with the stat's base value.
func setup(base_value: float) -> void:
	if not _is_stat_valid():
		return
	
	_base_value = base_value
	base_stat_value_label.text = str(_base_value)
	change_stat_value_label.text = ""

## Updates the display using stats from a LivingEntityStats object.
func update_from_stats(stats: LivingEntityStats) -> void:
	if not _is_stat_valid():
		return
	
	var stat_name: String = StatsEnums.stat_to_string(stat)
	var stat_value: float = stats.get(stat_name)
	update_change_value(stat_value)

## Updates the display to show the difference from the base value.
func update_change_value(current_value: float) -> void:
	if not _is_stat_valid():
		return
	
	var change: float = current_value - _base_value
	
	change_stat_value_label.text = "%.1f" % change if change != 0 else ""

func _is_stat_valid() -> bool:
	if stat == null:
		push_error("No stat type set for StatContainer: %s" % name)
		hide()
		return false
	return true
