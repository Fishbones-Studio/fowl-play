extends Ability

@export var max_blasts: int = 5
@export var blast_interval: float = 0.25
@export var blast_increment: float = 0.05
@export var stun_time: float = 0.15

var base_damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (max_blasts / blast_interval) * (1.0 + (stats.attack / 100))

var _target: Node3D = null
var _hit_bodies: Array = []
var _blast_count: int = 0
var _current_damage: float = 0.0

@onready var blast_timer: Timer = $BlastTimer
@onready var detection_area: Area3D = $DetectionArea
@onready var hit_area: Area3D = $HitArea
@onready var gpu_particles: GPUParticles3D = %GPUParticles3D
@onready var camera: FollowCamera = get_tree().get_first_node_in_group("FollowCamera")


func _ready() -> void:
	await get_tree().process_frame

	_toggle_collision_masks(true, detection_area)

	super()


func activate(_force_activate: bool = false) -> void:
	_target = _get_closest_target(detection_area)
	if _target == null:
		print("Cannot perform %s with no target in range." % name)
		return

	_hit_bodies.clear()
	_blast_count = 0
	_current_damage = base_damage

	_toggle_collision_masks(true, hit_area, true)

	# Reset to default settings
	gpu_particles.explosiveness = 0.0
	gpu_particles.amount = 1

	blast_timer.wait_time = blast_interval
	blast_timer.start()

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(_delta: float) -> void:
	if _target and not blast_timer.is_stopped():
		global_position = _target.global_position


func _get_closest_target(area: Area3D) -> Node3D:
	var target: Node3D = null
	var min_distance: float = INF

	for body in area.get_overlapping_bodies():
		if not (body.collision_layer in [2, 4]):
			continue

		var distance: float = ability_holder.global_position.distance_to(body.global_position)
		if distance < min_distance:
			min_distance = distance
			target = body

	return target


func _play_blast_sound_effect(times: int) -> void:
	for i in range(times):
		var blast_sfx: AudioStreamPlayer3D = sound_effect.duplicate() as AudioStreamPlayer3D
		add_child(blast_sfx)

		blast_sfx.pitch_scale = randf_range(0.9, 1.1)  # Add some variation
		blast_sfx.finished.connect(_on_blast_sfx_finished.bind(blast_sfx), CONNECT_ONE_SHOT)
		blast_sfx.play()


func _on_blast_timer_timeout() -> void:
	gpu_particles.restart()

	_blast_count += 1
	if _blast_count < max_blasts:
		_current_damage = base_damage * (1.0 + (_blast_count * blast_increment))
		blast_timer.start()
		sound_effect.play()
	elif _blast_count == max_blasts:
		gpu_particles.explosiveness = 1.0
		gpu_particles.amount = max_blasts
		_play_blast_sound_effect(max_blasts)
		_current_damage = base_damage * ((1.0 + 2 * (_blast_count * blast_increment)))
		blast_timer.start()
	else:
		gpu_particles.emitting = false
		_toggle_collision_masks(false, hit_area, true)
		return

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer in [2, 4]:  # Player or Enemy
			_hit_bodies.append(body)
			SignalManager.weapon_hit_target.emit(
				body,
				_current_damage,
				DamageEnums.DamageTypes.NORMAL,
				{
					"stun_time": stun_time
				},
			)

	if camera:
		camera.apply_shake(1.0 + (_blast_count * 0.1))

	_hit_bodies.clear()


func _on_blast_sfx_finished(sfx: AudioStreamPlayer3D) -> void:
	sfx.queue_free()
