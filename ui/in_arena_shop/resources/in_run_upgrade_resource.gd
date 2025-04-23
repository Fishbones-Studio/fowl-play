class_name InRunUpgradeResource
extends BaseResource

@export var health_bonus: float = 0.0
@export var stamina_bonus: float = 0.0
@export var attack_multiplier_bonus: float = 0.0
@export var defense_bonus: float = 0.0
@export var speed_bonus: float = 0.0
@export var weight_bonus: float = 0.0

func _init() -> void:
	type = ItemEnums.ItemTypes.UPGRADE

func get_bonus_string(use_bbcode := false) -> String:
	var bonuses_text: String = ""
	if health_bonus > 0:
		bonuses_text += ("[color=lime]" if use_bbcode else "") + "+%.0f Health" % health_bonus + ("[/color]" if use_bbcode else "") + "\n"
	if stamina_bonus > 0:
		bonuses_text += ("[color=yellow]" if use_bbcode else "") + "+%.1f Stamina" % stamina_bonus + ("[/color]" if use_bbcode else "") + "\n"
	if attack_multiplier_bonus > 0:
		bonuses_text += ("[color=red]" if use_bbcode else "") + "+%.0f%% Attack" % (attack_multiplier_bonus * 100.0) + ("[/color]" if use_bbcode else "") + "\n"
	if defense_bonus > 0:
		bonuses_text += ("[color=lightblue]" if use_bbcode else "") + "+%.1f Defense" % defense_bonus + ("[/color]" if use_bbcode else "") + "\n"
	if speed_bonus > 0:
		bonuses_text += ("[color=orange]" if use_bbcode else "") + "+%.1f Speed" % speed_bonus + ("[/color]" if use_bbcode else "") + "\n"
	if weight_bonus > 0:
		bonuses_text += ("[color=gray]" if use_bbcode else "") + "+%.1f Weight" % weight_bonus + ("[/color]" if use_bbcode else "") + "\n"
	return bonuses_text.strip_edges()
