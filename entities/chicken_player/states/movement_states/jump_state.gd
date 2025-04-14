extends BasePlayerMovementState

@export var air_jumps: int = 1
@onready var area_3d: Area3D = $"../../Area3D"
@onready var ground_pound_timer: Timer = $"../../Ground_Pound_Timer"
@onready var ability_1_cooldown: Timer = $"../../Ability1_Cooldown"
@onready var ground_pound_particles: CPUParticles3D = $"../../Area3D/Ground_Pound_Particles"


var ability1_available: bool = true
var _air_jumps_used: int = 0


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	if information.get("from_ground", false):
		_air_jumps_used = 0 # Reset air jumps if coming from the ground
	else:
		_air_jumps_used += 1 # Else increment air jumps used

	movement_component.jump_available = air_jumps > _air_jumps_used

	player.velocity.y = get_jump_velocity()


func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash") && movement_component.dash_available:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return
	if Input.is_action_just_pressed("Ability 1"):
		if ability1_available:
			perform_ground_pound()
		else:
			print(ability_1_cooldown.time_left)
		return
	
	
	if get_jump_velocity() > 0 and _air_jumps_used < air_jumps:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})


func process(delta: float) -> void:
	if is_sprinting():
		player.stats.drain_stamina(movement_component.sprint_stamina_cost * delta)
	else:
		player.stats.regen_stamina(delta)


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if player.velocity.y < 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	var speed_factor: float

	if is_sprinting():
		speed_factor = movement_component.sprint_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor

	var velocity: Vector3 = get_player_direction() * player.stats.calculate_speed(speed_factor)

	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()

	if not player.is_on_floor():
		return

	if velocity == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
	if Input.is_action_pressed("sprint"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return

	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})


func perform_ground_pound() -> void:
	#Edit Layer and mask so that Enemy gets hit when in the collision area
	area_3d.set_collision_layer_value(2, true)
	area_3d.set_collision_mask_value(1, true)
	area_3d.set_collision_mask_value(3, true)
	area_3d.set_collision_mask_value(4, true)
	area_3d.set_collision_mask_value(5, true)
	ground_pound_timer.start()
	ability_1_cooldown.start()
	player.velocity.y = -50
	ability1_available = false

	

func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body is Enemy:
		SignalManager.weapon_hit_target.emit(body, 30)
	else:
		print("No body found!")


func _on_ground_pound_timer_timeout() -> void:
	ground_pound_particles.emitting = true
	area_3d.set_collision_layer_value(2, false)
	area_3d.set_collision_mask_value(1, false)
	area_3d.set_collision_mask_value(3, false)
	area_3d.set_collision_mask_value(4, false)
	area_3d.set_collision_mask_value(5, false)


func _on_ability_1_cooldown_timeout() -> void:
	ability1_available = true
