class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes

@onready var health_bar: HealthBar = $SubViewport/HealthBar

func _ready() -> void:
	initialize_stats()
	initialize_health_bar()
	collision_layer = 4
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()

func get_stats_resource() -> LivingEntityStats:
	if stats == null:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats

func initialize_health_bar() -> void:
	if health_bar:
		health_bar.init_health(stats.max_health, stats.current_health)


func initialize_stats() -> void:
	if stats:
		stats.init()
	else:
		printerr("ERROR: Stats resource is NULL!")


func _take_damage(target: PhysicsBody3D, damage: float) -> void:
	if target == self:
		damage_taken.emit(stats.drain_health(damage))
		health_bar.set_health(stats.current_health)
		if stats.current_health <= 0:
			die()


func die() -> void:
	SignalManager.enemy_died.emit()
	print(name, " has died!")
	queue_free()
