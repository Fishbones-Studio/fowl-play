class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes
@export var enemy_model: Node3D
@export var animation_tree : AnimationTree

@onready var health_bar: HealthBar = $SubViewport/HealthBar


func _ready() -> void:
	initialize_stats()
	initialize_health_bar()
	collision_layer = 4
	SignalManager.weapon_hit_target.connect(_take_damage)
	GameManager.current_enemy = self


func _physics_process(_delta: float) -> void:
	move_and_slide()
	
func _exit_tree() -> void:
	GameManager.current_enemy = null


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


func die() -> void:
	SignalManager.enemy_died.emit()
	print(name, " has died!")
	queue_free()


func _take_damage(target: PhysicsBody3D, damage: int, type: DamageEnums.DamageTypes) -> void:
	if target == self:
		damage_taken.emit(stats.drain_health(damage, type))
		health_bar.set_health(stats.current_health)
		if stats.current_health <= 0:
			die()
