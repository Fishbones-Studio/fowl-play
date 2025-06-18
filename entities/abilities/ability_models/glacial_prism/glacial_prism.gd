extends Ability

@export_range(1, 100, 0.1) var movement_debuff: float = 80.0
@export_range(1, 100, 0.1) var defense_debuff: float = 50.0
@export var debuff_duration: float = 8.0
@export var damage_scaler: float = 4.5
@export var impact_time: float = 0.3

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (damage_scaler * stats.speed) * (1.0 + (stats.attack / 100))

var _target: Node3D = null
var _hit_bodies: Array = []

@onready var impact_timer: Timer = $ImpactTimer
@onready var detection_area: Area3D = $DetectionArea
@onready var hit_area: Area3D = $HitArea
@onready var crystal_particle: GPUParticles3D = %Crystal


func _ready() -> void:
	await get_tree().process_frame

	_toggle_collision_masks(true, detection_area)

	super()


func activate(force_activate: bool = false) -> void:
	_target = _get_closest_target(detection_area)

	if not _target:
		print("Cannot perform %s with no target in range." % name)
		return

	_hit_bodies.clear()

	_toggle_collision_masks(true, hit_area)

	impact_timer.wait_time = impact_time
	impact_timer.start()

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(_delta: float) -> void:
	if _target and not crystal_particle.emitting:
		global_position = _target.global_position


func _apply_debuff(body: Node3D, stat_name: StringName, amount: float) -> void:
	if body is CharacterBody3D:
		if not body.has_method("get_stats_resource"):
			return

		var stats: LivingEntityStats = body.get_stats_resource()

		var original_value: float = stats.apply_stat_effect(stat_name, -amount)

		get_tree().create_timer(debuff_duration).timeout.connect(func():
			if is_instance_valid(stats):
				stats.set(stat_name, original_value)
		)


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


func _on_impact_timer_timeout() -> void:
	crystal_particle.restart()
	sound_effect.play()

	await get_tree().create_timer(0.3).timeout

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer in [2, 4]:  # Player or Enemy
			_hit_bodies.append(body)
			SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
			_apply_debuff(body, &"speed", movement_debuff)
			_apply_debuff(body, &"defense", defense_debuff)

	_toggle_collision_masks(false, hit_area)

	_hit_bodies.clear()
