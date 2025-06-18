extends Ability

@export var max_slashes: int = 2
@export var slash_interval: float = 0.2
@export var ignore_defense: bool = true
@export var base_damage: float = 25.0

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return base_damage * (1.0 + (stats.attack / 100))

var _hit_bodies: Array = []
var _current_slash_count: int = 0 

@onready var slash_timer: Timer = $SlashTimer
@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate(force_activate: bool = false) -> void:
	_toggle_collision_masks(true, hit_area)

	_hit_bodies.clear()
	_current_slash_count = 0 

	slash_timer.wait_time = slash_interval
	slash_timer.start()

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _on_slash_timer_timeout() -> void:
	sound_effect.play()
	cpu_particles.restart()

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer in [2, 4]:  # Player or Enemy
			SignalManager.weapon_hit_target.emit(
				body, 
				damage, 
				DamageEnums.DamageTypes.NORMAL if not ignore_defense else DamageEnums.DamageTypes.TRUE
			)
			_hit_bodies.append(body)

	cpu_particles.emitting = true

	_current_slash_count += 1
	if _current_slash_count < max_slashes:
		slash_timer.start()
	else:
		_toggle_collision_masks(false, hit_area)

	_hit_bodies.clear()
