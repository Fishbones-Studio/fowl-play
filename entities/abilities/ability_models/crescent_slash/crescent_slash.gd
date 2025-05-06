extends Ability

@export_range(1, 3) var strike_amount: int = 2
@export var ignore_defense: bool = true

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (15) * ((1.0 + (stats.attack / 100)) + 1.2)

var _particles_emitted: bool = false
var _hit_bodies: Array = []

@onready var slash_timer: Timer = $SlashTimer
@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func activate() -> void:
	_toggle_collision_masks(true, hit_area)

	cpu_particles.amount = strike_amount
	cpu_particles.emitting = true
	slash_timer.wait_time = cpu_particles.lifetime

	_particles_emitted = true
	_hit_bodies.clear()

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	# Crack, it only syncs if strikes is 2, if higher, doesn't match that well, to lazy to fix
	for i in strike_amount:
		audio_stream_player.play()
		await get_tree().create_timer(0.35).timeout
		audio_stream_player.stop()

	cooldown_timer.start()
	slash_timer.start()


func _physics_process(_delta: float) -> void:
	if not _particles_emitted:
		return

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			for i in strike_amount:
				if is_instance_valid(body):
					SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL if not ignore_defense else DamageEnums.DamageTypes.TRUE)

			_hit_bodies.append(body)


func _on_slash_timer_timeout() -> void:
	_hit_bodies.clear()
	_particles_emitted = false

	_toggle_collision_masks(false, hit_area)
