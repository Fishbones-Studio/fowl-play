extends Ability

@export_range(1, 100, 0.1) var movement_debuff: float = 50.0
@export var debuff_duration: float = 5.0
@export var damage_scaler: float = 3

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (damage_scaler * stats.speed) * (1.0 + (stats.attack / 100))

var _attack_duration: float = 0.0
var _hit_bodies: Array = []

@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	if not ability_holder.is_on_floor():
		print("Cannot perform %s while airborne." % name)
		return

	_attack_duration = cpu_particles.lifetime
	_hit_bodies.clear()

	cpu_particles.emitting = true

	_toggle_collision_masks(true, hit_area)

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(delta: float) -> void:
	_attack_duration -= delta

	if _attack_duration <= 0:
		_toggle_collision_masks(false, hit_area)
		_attack_duration = 0.0

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
			_apply_debuff(body)
			_hit_bodies.append(body)


func _apply_debuff(body: Node3D) -> void:
	if body is CharacterBody3D:
		if not body.has_method("get_stats_resource"):
			return

		var stats: LivingEntityStats = body.get_stats_resource()

		var original_speed: float = stats.apply_stat_effect("speed", movement_debuff)

		get_tree().create_timer(debuff_duration).timeout.connect(func():
			if is_instance_valid(stats):
				stats.speed = original_speed
		)
