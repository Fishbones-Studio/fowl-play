class_name HealthBar
extends ProgressBar

@onready var timer := $Timer
@onready var damage_bar := $DamageBar
@onready var health_bar := self 


var health: float:
	set = set_health


func _ready() -> void:
	pass 


func change_healthbar_appearance(color: Color, top_right_radius: int, bottom_right_radius: int, top_left_radius: int = 0, bottom_left_radius: int = 0) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.corner_radius_top_left = top_left_radius
	style_box.corner_radius_top_right = top_left_radius
	style_box.corner_radius_bottom_left = bottom_left_radius
	style_box.corner_radius_bottom_right = bottom_right_radius
	health_bar.add_theme_stylebox_override("fill", style_box)


func set_damage_bar_color(color: Color) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	damage_bar.add_theme_stylebox_override("fill", style_box)


func set_health(_health: float) -> void:
	if _health == health:
		return

	var prev_health: float = health
	health = min(max_value, _health)

	value = health

	if health <= prev_health:
		timer.start()
	else:
		_on_timer_timeout()


func init_health(_max_health: int, _health: int) -> void:
	print("init_health")
	health = _health
	max_value = _max_health
	value = health
	damage_bar.max_value = _max_health
	damage_bar.value = health


func _on_timer_timeout() -> void:
	damage_bar.value = health
