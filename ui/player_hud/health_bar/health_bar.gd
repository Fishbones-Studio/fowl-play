class_name HealthBar
extends ProgressBar

@export var high_health_color: Color = Color.GREEN
@export var medium_health_color: Color = Color.ORANGE
@export var critical_health_color: Color = Color.RED

var health: float:
	set = set_health

@onready var timer: Timer= $Timer
@onready var damage_bar: ProgressBar = $DamageBar


func _ready() -> void:
	# Set initial color
	_update_health_color()


func _update_health_color() -> void:
	var health_percent: float = health / max_value if max_value > 0 else 1.0

	var current_color: Color
	if health_percent > 0.55:
		current_color = high_health_color
	elif health_percent > 0.20:
		current_color = medium_health_color
	else:
		current_color = critical_health_color

	var original_style_box := get_theme_stylebox("fill") as StyleBoxFlat
	if original_style_box:
		var style_box = original_style_box.duplicate() as StyleBoxFlat
		style_box.bg_color = current_color
		add_theme_stylebox_override("fill", style_box)




func set_health(_health: float) -> void:
	if _health == health:
		return
	elif health <= 0:
		health = _health
		return
	
	var prev_health: float = health
	health = _health
	
	value = _health
	
	_update_health_color()
	
	if health <= prev_health:
		timer.start()
	else:
		if health > prev_health:
			timer.stop()
		_on_timer_timeout()


func init_health(_max_health: float, _health: float) -> void:
	print("init_health")
	health = _health
	max_value = _max_health
	value = health
	damage_bar.max_value = max_value
	damage_bar.value = value
	_update_health_color()


func _on_timer_timeout() -> void:
	damage_bar.max_value = max_value
	damage_bar.value = health
