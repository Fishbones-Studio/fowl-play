class_name StaminaBar
extends ProgressBar

var stamina: float:
	set = set_stamina


func init(max_stamina: float, stamina: float) -> void:
	value = stamina
	max_value = max_stamina


func set_stamina(sta: float):
	stamina = min(max_value, sta)
	value = stamina 
