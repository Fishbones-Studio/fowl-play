class_name BaseRangedCombatState
extends BaseState

@export var ANIMATION_NAME: String
@export var state_type: WeaponEnums.WeaponState

var weapon: RangedWeapon
var transition_signal : Signal
var origin_entity : PhysicsBody3D ## The entity that is using the weapon


func setup(_weapon_node: RangedWeapon, _transition_signal : Signal) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	
	if not _transition_signal:
		print("Transition signal does not exist! Please provide a valid signal.")
		return
		
	
	weapon = _weapon_node
	transition_signal = _transition_signal


func enter(_previous_state, _information: Dictionary = {}) -> void:
	pass
	
func process_hit(raycast: RayCast3D) -> void:
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		
		if collider is PhysicsBody3D:
			DebugDrawer.draw_debug_impact(collider.global_position, collider)
			if collider == origin_entity:
				print("Hit self")
				return
			print("Colliding with:" + collider.name)
			SignalManager.weapon_hit_target.emit(collider, weapon.current_weapon.damage)
	# Clean up raycast
	raycast.queue_free()
