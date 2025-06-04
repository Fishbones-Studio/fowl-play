extends Ability

@export var max_blasts: int = 5
@export var blasts_interval: float = 0.25
@export var stun_time: float = 0.1

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return 10

var target: Node3D = null

var _hit_bodies: Array = []
var _blast_count: int = 0

@onready var blast_timer: Timer = $BlastTimer
@onready var detection_area: Area3D = $DetectionArea
@onready var hit_area: Area3D = $HitArea
@onready var gpu_particles: GPUParticles3D = %GPUParticles3D


func _ready() -> void:
	await get_tree().process_frame

	_toggle_collision_masks(true, detection_area)


func activate() -> void:
	target = _get_closest_target(detection_area)
	if target == null:
		print("Cannot perform %s with no target in range." % name)
		return

	_hit_bodies.clear()
	_blast_count = 0

	_toggle_collision_masks(true, hit_area)

	blast_timer.wait_time = blasts_interval
	blast_timer.start()

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(_delta: float) -> void:
	if target and not blast_timer.is_stopped(): 
		global_position = target.global_position


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


func _on_blast_timer_timeout() -> void:
	gpu_particles.restart()

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer in [2, 4]:  # Player or Enemy
			_hit_bodies.append(body)
			SignalManager.weapon_hit_target.emit(
				body,
				damage,
				DamageEnums.DamageTypes.NORMAL,
				{
					"stun_time": stun_time
				},
			)

	gpu_particles.emitting = true

	_blast_count += 1
	if _blast_count < max_blasts:
		blast_timer.start()
	else:
		_toggle_collision_masks(false, hit_area)

	_hit_bodies.clear()
