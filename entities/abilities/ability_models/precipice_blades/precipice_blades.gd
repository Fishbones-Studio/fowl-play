extends Ability

@export var strike_amount: int = 2

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return stats.attack * 2.2

var _particles_emitted: bool = false
var _hit_bodies: Array = []

@onready var slash_timer: Timer = $SlashTimer
@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	_toggle_collision_masks(true)

	cpu_particles.amount = strike_amount
	cpu_particles.emitting = true
	slash_timer.wait_time = cpu_particles.lifetime

	_particles_emitted = true

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()
	slash_timer.start()


func _on_cooldown_timer_timeout() -> void:
	_particles_emitted = false


func _physics_process(_delta: float) -> void:
	if not _particles_emitted:
		return

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			for i in strike_amount:
				SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
			_hit_bodies.append(body)


func _on_slash_timer_timeout() -> void:
	_hit_bodies.clear()

	_toggle_collision_masks(false)


func _toggle_collision_masks(toggle: bool) -> void:
	if ability_holder.collision_layer == 2: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4: # Enemy
		hit_area.set_collision_mask_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle) # World
