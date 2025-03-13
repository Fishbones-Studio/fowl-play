extends ProgressBar
class_name StaminaBar

var stamina: int:
	set = set_stamina


func set_stamina(_stamina: int):
	stamina = min(max_value, _stamina)
	value = stamina


func init_stamina(_max_stamina: int, _stamina: int) -> void:
	stamina = _stamina
	max_value = _max_stamina
	value = stamina
