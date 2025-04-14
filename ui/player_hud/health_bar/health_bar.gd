class_name HealthBar
extends ProgressBar

@onready var timer := $Timer
@onready var damage_bar := $DamageBar

@export var tracked_entity: Node = null
@export var high_health_color: Color = Color.GREEN
@export var medium_health_color: Color = Color.ORANGE
@export var critical_health_color: Color = Color.RED


var health: float:
	set = set_health


func _ready() -> void:
	# Set initial color
	_update_health_color()
	
	if tracked_entity:
		bind_signals()


func bind_signals() -> void:
	if tracked_entity:
		SignalManager.enemy_stats_changed.connect(_on_enemy_stats_changed)


func _update_health_color() -> void:
	var health_percent := health / max_value if max_value > 0 else 1.0
	
	var current_color: Color
	if health_percent > 0.55:
		current_color = high_health_color
	elif health_percent > 0.20:
		current_color = medium_health_color
	else:
		current_color = critical_health_color
	
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = current_color
	add_theme_stylebox_override("fill", style_box)


# Rest of the functions remain the same...
func set_health(_health: float) -> void:
	if _health == health:
		return
	
	var prev_health := health
	health = _health
	value = _health
	
	_update_health_color()

	if health <= prev_health:
		timer.start()
		SignalManager.player_hurt.emit()
	else:
		if health > prev_health:
			timer.stop()
			SignalManager.player_heal.emit()
		_on_timer_timeout()


func init_health(_max_health: int, _health: int) -> void:
	max_value = _max_health
	health = _health
	value = health
	damage_bar.max_value = max_value
	damage_bar.value = value
	_update_health_color()


func _on_timer_timeout() -> void:
	damage_bar.max_value = max_value
	damage_bar.value = health


func _on_enemy_stats_changed(entity: Node, stats: LivingEntityStats) -> void:
	if entity == tracked_entity:
		max_value = stats.max_health
		health = stats.current_health
		_update_health_color()
