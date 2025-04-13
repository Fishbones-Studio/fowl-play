class_name HealthBar
extends ProgressBar

@onready var timer := $Timer
@onready var damage_bar := $DamageBar
@onready var health_bar := self 

var health: float:
	set = set_health


func change_healthbar_appearance(color: Color) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	
	health_bar.add_theme_stylebox_override("fill", style_box)

func set_health(_health: float) -> void:
	if _health == health:
		return
	elif health <= 0:
		health = _health
		return
	
	var prev_health: float = health
	health = _health
	
	value = _health

	if health <= prev_health:
		timer.start()
		SignalManager.player_hurt.emit()
	else:
		if health > prev_health:
			timer.stop()
			SignalManager.player_heal.emit()
		_on_timer_timeout()


func init_health(_max_health: int, _health: int) -> void:
	print("init_health")
	health = _health
	max_value = _max_health
	value = health
	damage_bar.max_value = max_value
	damage_bar.value = value


func _on_timer_timeout() -> void:
	damage_bar.max_value = max_value
	damage_bar.value = health
