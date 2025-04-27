extends VBoxContainer

@onready var health_bar: HealthBar = %BossHealthBar

# TODO: rotate healthbar, get name of boss to appear instead of placeholder,
# attach actual health of boss to healthbar

func _ready() -> void:
	visible = false
	
	SignalManager.init_health.connect(health_bar.init_health)
	SignalManager.boss_stats_changed.connect(_on_stats_changed)
	SignalManager.boss_appeared.connect(_on_boss_appeared)

func _on_stats_changed(stats: LivingEntityStats) -> void:
	health_bar.max_value = stats.max_health
	health_bar.health = stats.current_health

func _on_boss_appeared(visible: bool) -> void:
	self.visible = visible
