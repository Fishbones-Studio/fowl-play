class_name Enemy
extends CharacterBody3D

@export var stats: LivingEntityStats

@onready var health_bar: HealthBar = $SubViewport/HealthBar
@onready var damage_label: Marker3D = $Marker3D

func _ready() -> void:
	initialize_stats()
	initialize_health_bar()
	collision_layer = 4
	collision_mask = 27
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func initialize_health_bar() -> void:
	if health_bar:
		health_bar.init_health(stats.max_health, stats.current_health)


func initialize_stats() -> void:
	if stats:
		stats.init()
	else:
		printerr("ERROR: Stats resource is NULL!")


func _take_damage(target: PhysicsBody3D, damage: int) -> void:
	print("The target: " + target.name)
	if target == self:
		stats.drain_health(damage)
		spawn_damage_popup(damage)
		health_bar.set_health(stats.current_health)
		if stats.current_health <= 0:
			die()


func spawn_damage_popup(damage: int) -> void:
	var damage_popup = preload("uid://b6cnb1t5cixqj").instantiate()
	get_parent().add_child(damage_popup)

	var spawn_position: Vector3 = damage_label.global_position + Vector3(
		randf_range(-damage_popup.horizontal_spread, damage_popup.horizontal_spread),
		randf_range(0, damage_popup.vertical_variance),
		randf_range(-damage_popup.depth_offset, damage_popup.depth_offset)
	)

	damage_popup.global_position = spawn_position
	damage_popup.display_damage(damage)


func die() -> void:
	print("BaseEnemy died!")
	queue_free()
