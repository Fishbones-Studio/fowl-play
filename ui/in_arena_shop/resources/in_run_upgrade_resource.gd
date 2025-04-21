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


func get_bonus_string() -> String:
	var bonuses_text: String = ""
	if health_bonus > 0:
		bonuses_text += "+%d Health\n" % health_bonus
	if stamina_bonus > 0:
		bonuses_text += "+%.2f Stamina\n" % stamina_bonus
	if attack_multiplier_bonus > 0:
		bonuses_text += "+%.2f Attack Multiplier\n" % float(attack_multiplier_bonus * 100)
	if defense_bonus > 0:
		bonuses_text += "+%.2f Defense\n" % defense_bonus
	if speed_bonus > 0:
		bonuses_text += "+%.2f Speed\n" % speed_bonus
	if weight_bonus > 0:
		bonuses_text += "+%.2f Weight\n" % weight_bonus

	return bonuses_text.strip_edges()  
