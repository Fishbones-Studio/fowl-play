class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes
@export var enemy_model: Node3D

@onready var health_bar: HealthBar = %HealthBar
@onready var bt_player: BTPlayer = $BTPlayer
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@onready var enemy_weapon_controller: EnemyWeaponController = $EnemyWeaponController
@onready var enemy_ability_controller: EnemyAbilityController = $EnemyAbilityController
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_initialize_stats()
	_initialize_health_bar()
	collision_layer = 4
	SignalManager.weapon_hit_target.connect(_take_damage)
	GameManager.current_enemy = self


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()


func _process(_delta: float) -> void:
	SignalManager.boss_stats_changed.emit(stats)


func get_stats_resource() -> LivingEntityStats:
	if stats == null:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats


func _initialize_stats() -> void:
	if stats:
		stats.init()
	else:
		printerr("ERROR: Stats resource is NULL!")


func _initialize_health_bar() -> void:
	if health_bar:
		health_bar.init_health(stats.max_health, stats.current_health)


func _take_damage(target: PhysicsBody3D, damage: float, damage_type: DamageEnums.DamageTypes) -> void:
	if target == self:
		damage_taken.emit(stats.drain_health(damage, damage_type))
		health_bar.set_health(stats.current_health)
		if stats.current_health <= 0:
			_die()


func _die() -> void:
	SignalManager.enemy_died.emit()
	print(name, " has died!")
	queue_free()


## Applies jump or fall gravity based on velocity
func apply_gravity(delta: float) -> void:
	velocity.y += movement_component.get_gravity(velocity) * delta
