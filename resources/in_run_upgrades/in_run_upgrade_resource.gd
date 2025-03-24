class_name InRunUpgradeResource
extends BaseResource



@export var health_bonus: int = 0  
@export var speed_bonus: float = 0.0  
@export var damage_bonus: float = 0.0  


func _init() -> void:
	type = ItemEnums.ItemTypes.UPGRADE

func get_bonus_string() -> String:
	var bonuses_text = ""
	if health_bonus > 0:
		bonuses_text += "+%d Health\n" % health_bonus
	if speed_bonus > 0:
		bonuses_text += "+%.2f Speed\n" % speed_bonus
	if damage_bonus > 0:
		bonuses_text += "+%.2f Damage\n" % damage_bonus
	
	return bonuses_text.strip_edges()  #
