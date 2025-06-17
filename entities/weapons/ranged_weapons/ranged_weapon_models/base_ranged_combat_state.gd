class_name BaseRangedCombatState
extends BaseState

@export var animation_name: String
@export var state_type: WeaponEnums.WeaponState

var weapon: RangedWeapon
var transition_signal: Signal

func setup(_weapon_node: RangedWeapon, _transition_signal : Signal) -> void:
	if not _weapon_node:
		push_error("Weapon does not exist! Please provide a valid weapon node.")
		return

	if not _transition_signal:
		push_error("Transition signal does not exist! Please provide a valid signal.")
		return

	weapon = _weapon_node
	transition_signal = _transition_signal


func enter(_previous_state, _information: Dictionary = {}) -> void:
	pass


func process_raycast_hit(raycast: RayCast3D, damage_type : DamageEnums.DamageTypes = DamageEnums.DamageTypes.NORMAL) -> void:
	# make the raycast immediately check for collisions
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		print("Raycast hit: " + collider.name)

		if collider is PhysicsBody3D:
			DebugDrawer.draw_debug_impact(raycast.get_collision_point(), collider)
			print("Colliding with:" + collider.name)
			# TODO: hit marker
			SignalManager.weapon_hit_target.emit(collider, weapon.entity_stats.calc_scaled_damage(weapon.current_weapon.damage), damage_type)
