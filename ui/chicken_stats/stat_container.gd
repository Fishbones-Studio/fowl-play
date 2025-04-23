class_name StatContainer
extends HBoxContainer

@export var stat: StatsEnums.Stat
@export var corner_radius: Vector4i = Vector4i(0, 0, 0, 0)

@onready var stat_label: Label = $StatLabel
@onready var stat_value_label: Label = $StatValueLabel


func _ready() -> void:
	if not stat:
		push_error("No stat set for stat container: ", self.name)
		return

	var stat_name: String = StatsEnums.stat_to_string(stat)
	var stat_value: float = GameManager.chicken_player.stats.get(stat_name)

	stat_label.text = stat_name
	stat_label.text = str(stat_value if stat_value else -1)

	_apply_stylebox_corners(stat_label.get_theme_stylebox("normal"), false)
	_apply_stylebox_corners(stat_label.get_theme_stylebox("normal"), true)


func _apply_stylebox_corners(stylebox: StyleBox, is_value: bool) -> void:
	if not stylebox:
		push_warning("Non existent stylebox in: ", self.name)
		return

	if is_value:
		stylebox.corner_radius_top_right = corner_radius.y
		stylebox.corner_radius_bottom_right = corner_radius.z
	else:
		stylebox.corner_radius_top_left = corner_radius.x
		stylebox.corner_radius_bottom_left = corner_radius.w
