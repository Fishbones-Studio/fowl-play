extends VBoxContainer

@onready var health_bar: HealthBar = %HealthBar
@onready var stamina_bar: StaminaBar = %StaminaBar


func _ready() -> void:
	# Initializing the health and stamina bars
	SignalManager.init_health.connect(health_bar.init_health)
	SignalManager.init_stamina.connect(stamina_bar.init)

	SignalManager.player_stats_changed.connect(_on_stats_changed)


func _on_stats_changed(stats: LivingEntityStats) -> void:
	# updating the max values
	health_bar.max_value = stats.max_health
	stamina_bar.max_value = stats.max_stamina

	# trigger hurt and health shaders
	if stats.current_health < health_bar.health:
		SignalManager.player_hurt.emit()
	elif stats.current_health > health_bar.health:
		SignalManager.player_heal.emit()

	health_bar.health = stats.current_health
	stamina_bar.stamina = stats.current_stamina
