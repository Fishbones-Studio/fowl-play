class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes
@export var enemy_model: Node3D
@export var knockback_decay: int = 50 # Rate at which the knockback decays per second

var is_immobile: bool = false
var _knockback: Vector3 = Vector3.ZERO

@onready var health_bar: HealthBar = %HealthBar
@onready var bt_player: BTPlayer = $BTPlayer
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@onready var enemy_weapon_controller: EnemyWeaponController = $EnemyWeaponController
@onready var enemy_ability_controller: EnemyAbilityController = $EnemyAbilityController
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var shape: CollisionShape3D = $CollisionShape3D
@onready var immobile_timer: Timer = $ImmobileTimer


func _ready() -> void:
	stats.init()
	health_bar.init_health(stats.max_health, stats.current_health)

	collision_layer = 4
	GameManager.current_enemy = self
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	if is_immobile:
		velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	move_and_slide()


func get_stats_resource() -> LivingEntityStats:
	if stats == null:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats


func _take_damage(target: PhysicsBody3D, damage: float, damage_type: DamageEnums.DamageTypes, info: Dictionary = {}) -> void:
	if target == self:
		if "knockback" in info:
			# Set knockback force
			_knockback = info["knockback"]

			if not velocity.is_equal_approx(Vector3.ZERO):
				_knockback *= 2

			# Set immobile time
			immobile_timer.wait_time = _knockback.length() / knockback_decay
			immobile_timer.start()
			is_immobile = true

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


func _on_immobile_timer_timeout() -> void:
	is_immobile = false
