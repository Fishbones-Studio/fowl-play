class_name StaminaBar
extends ProgressBar

var stamina: float:
	set = set_stamina


func init(max_stamina: float, current_stamina: float) -> void:
	value = current_stamina
	max_value = max_stamina


func set_stamina(_stamina: float) -> void:
	if _stamina == stamina:
		return
	stamina = min(max_value, _stamina)
	value = stamina 
