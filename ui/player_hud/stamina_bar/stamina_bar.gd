extends ProgressBar
class_name StaminaBar

var stamina: float:
	set = set_stamina


func set_stamina(_stamina: float):
	stamina = min(max_value, _stamina)
	value = stamina


func init_stamina(_max_stamina: float, _stamina: float) -> void:
	print("init_stamina")
	stamina = _stamina
	max_value = _max_stamina
	value = stamina
