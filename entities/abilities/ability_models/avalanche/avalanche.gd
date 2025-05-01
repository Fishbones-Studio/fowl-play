extends Ability

@export_range(1, 100, 0.1) var defense_debuff: float = 50.0
@export var debuff_duration: float = 5.0

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (stats.attack + stats.speed) * 1.1

var _target_stats: LivingEntityStats
var _original_defense: float

@onready var debuff_timer: Timer = %DebuffTimer
@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	if not ability_holder.is_on_floor():
		print("Cannot perform %s while airborne." % name)
		return

	cpu_particles.emitting = true

	_toggle_collision_masks(true)

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _apply_debuff(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("get_stats_resource"):
		_target_stats = body.get_stats_resource()

		_original_defense = _target_stats.defense
		_target_stats.defense = _original_defense * (1 - defense_debuff / 100)

		debuff_timer.start(debuff_duration)


func _toggle_collision_masks(toggle: bool) -> void:
	if ability_holder.collision_layer == 2: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4: # Enemy
		hit_area.set_collision_mask_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle) # World


func _on_debuff_timer_timeout() -> void:
	if is_instance_valid(_target_stats):
		_target_stats.defense = _original_defense


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.collision_layer == 2: # Player
		SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
	if body.collision_layer == 4: # Enemy
		SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)

	_apply_debuff(body)

	_toggle_collision_masks(false)

	if ability_holder == ChickenPlayer:
		SignalManager.deactivate_item_slot.emit(current_ability)
