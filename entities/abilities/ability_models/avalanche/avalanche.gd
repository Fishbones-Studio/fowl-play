extends Ability

@export_range(1, 100, 0.1) var movement_debuff: float = 50.0
@export var debuff_duration: float = 5.0

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (stats.attack + stats.speed) * 1.1

var _attack_duration: float = 0.0
var _hit_bodies: Array = []
var _target_stats: LivingEntityStats
var _original_speed: float

@onready var debuff_timer: Timer = %DebuffTimer
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

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
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

		_target_stats = body.get_stats_resource()

		_original_speed = _target_stats.speed
		_target_stats.speed = _original_speed * (1 - movement_debuff / 100)

		debuff_timer.start(debuff_duration)


func _on_debuff_timer_timeout() -> void:
	if is_instance_valid(_target_stats):
		_target_stats.speed = _original_speed
