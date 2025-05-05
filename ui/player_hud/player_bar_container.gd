extends VBoxContainer

enum EntityTypes { Chicken, Enemy }
@export var entity_type: EntityTypes  

@export var health_bar: HealthBar
@export var stamina_bar: StaminaBar 
@export var name_label: Label

@onready var enemy_bar_container: VBoxContainer = %EnemyBarContainer
@onready var vs_label: Label = %VSLabel

func _ready() -> void:
	if name_label:
		name_label.visible = false
		
	enemy_bar_container.visible = false
	vs_label.visible = false
	
	match entity_type:
		EntityTypes.Chicken:
			if health_bar:
				SignalManager.init_health.connect(health_bar.init_health)
			if stamina_bar:
				SignalManager.init_stamina.connect(stamina_bar.init)
			SignalManager.player_stats_changed.connect(_on_stats_changed)
		EntityTypes.Enemy:
			if health_bar:
				SignalManager.init_health.connect(health_bar.init_health)
			SignalManager.enemy_appeared.connect(_on_enemy_appeared)
			SignalManager.enemy_stats_changed.connect(_on_stats_changed)

func _on_enemy_appeared(visible: bool) -> void:
	enemy_bar_container.visible = visible
	vs_label.visible = visible
	
func _on_stats_changed(stats: LivingEntityStats) -> void:
	if health_bar:
		health_bar.max_value = stats.max_health
		health_bar.health = stats.current_health

	if name_label:
		name_label.visible = true
		name_label.text = stats.name

	# Only handle stamina and effects for player
	if entity_type == EntityTypes.Chicken:
		if stamina_bar:
			stamina_bar.max_value = stats.max_stamina
			stamina_bar.stamina = stats.current_stamina
		
		if stats.current_health < health_bar.health:
			SignalManager.player_hurt.emit()
		elif stats.current_health > health_bar.health:
			SignalManager.player_heal.emit()
