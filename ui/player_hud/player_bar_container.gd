extends VBoxContainer

@export var health_bar: HealthBar 
@export var stamina_bar: StaminaBar 
@export var name_label: Label


func _ready() -> void:
	# Initialize health bar
	if health_bar:
		SignalManager.init_health.connect(health_bar.init_health)

	# Initialize stamina bar only if it exists
	if stamina_bar:
		SignalManager.init_stamina.connect(stamina_bar.init)

	SignalManager.player_stats_changed.connect(_on_player_stats_changed)
	SignalManager.enemy_stats_changed.connect(_on_enemy_stats_changed)


func _on_player_stats_changed(stats: LivingEntityStats) -> void:
	if health_bar:
		health_bar.max_value = stats.max_health
		health_bar.health = stats.current_health

	if stamina_bar:
		stamina_bar.max_value = stats.max_stamina
		stamina_bar.stamina = stats.current_stamina

	if name_label:
		name_label.text = stats.name

	# Trigger hurt/heal effects only for player
	if stats.current_health < health_bar.health:
		SignalManager.player_hurt.emit()
	elif stats.current_health > health_bar.health:
		SignalManager.player_heal.emit()


func _on_enemy_stats_changed(stats: LivingEntityStats) -> void:
	if health_bar:
		health_bar.max_value = stats.max_health
		health_bar.health = stats.current_health

	if name_label:
		name_label.text = stats.name
