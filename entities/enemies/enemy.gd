class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes
@export var knockback_decay: int = 50 ## Rate at which the knockback decays per second
@export_dir var dialogue_path: String
@export var name_label_template_string: String ## String template, requires 1 %s which will be replaced with the name specified in the associated stats
@export var model: Node3D 
@export var hurt_sound : AudioStream
@export var apply_gravity: bool = true

var is_immobile: bool = false
var is_stunned: bool = false
var hurt_ticks: Array = []

var _knockback: Vector3 = Vector3.ZERO

@onready var health_bar: HealthBar = %EnemyHealthBar
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@onready var enemy_weapon_controller: EnemyWeaponController = $EnemyWeaponController
@onready var enemy_ability_controller: EnemyAbilityController = $EnemyAbilityController
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var shape: CollisionShape3D = $CollisionShape3D
@onready var immobile_timer: Timer = $ImmobileTimer
@onready var blood_splash_handler: BloodSplashHandler = %BloodSplashHandler
@onready var state_audio_player: AudioStreamPlayer3D = %StateAudioPlayer
@onready var interval_audio_player: IntervalSFXPlayer3D = %IntervalAudioPlayer
@onready var bt_player: BTPlayer = %BTPlayer


func _ready() -> void:
	if not stats:
		push_error("Enemy stats resource is not assigned! Please assign a LivingEntityStats resource to the enemy.")
		return

	stats.init()
	health_bar.init_health(stats.max_health, stats.current_health)
	enemy_name_label.text = name_label_template_string % stats.name.capitalize()

	collision_layer = 4
	GameManager.current_enemy = self
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(delta: float) -> void:
	if apply_gravity: 
		_apply_gravity(delta)

	if is_immobile:
		velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)
	if is_stunned and _knockback.is_zero_approx():
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func _process(_delta: float) -> void:
	stats.regen_stamina(stats.stamina_regen)
	stats.regen_health(stats.health_regen)

	health_bar.set_health(stats.current_health)

	if stats.current_health <= 0:
		_die()
		bt_player.active = false
		set_process(false)


func get_stats_resource() -> LivingEntityStats:
	if not stats:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats


## Applies jump or fall gravity based on velocity
func _apply_gravity(delta: float) -> void:
	velocity.y += movement_component.get_gravity(velocity) * delta


func play_state_audio(audio_stream: AudioStream, stop_interval := true) -> void:
	if stop_interval:
		# Stop the interval audio and timer
		interval_audio_player.stop()
		interval_audio_player.random_player.timer.stop()

	# Set up the state audio player
	state_audio_player.stream = audio_stream
	state_audio_player.play()

	# Connect to finished signal and play state audio
	if not state_audio_player.finished.is_connected(_on_state_audio_finished.bind(stop_interval)):
		state_audio_player.finished.connect(_on_state_audio_finished, CONNECT_ONE_SHOT)


func _on_state_audio_finished(resume_interval := true) -> void:
	if resume_interval:
		# Resume interval timer
		interval_audio_player.random_player.timer.start()


func _take_damage(target: PhysicsBody3D, damage: float, damage_type: DamageEnums.DamageTypes, info: Dictionary = {}) -> void:
	if target == self:
		var immobile_time: float = 0.0
		if "knockback" in info:
			# Set knockback force
			_knockback = info["knockback"]

			if not velocity.is_zero_approx():
				_knockback *= 2

			# Set immobile time
			immobile_time = _knockback.length() / knockback_decay

		if "stun_time" in info:
			var stun_time: float = info["stun_time"]

			if stun_time > immobile_time:
				immobile_time = stun_time
				is_stunned = true

		if not is_zero_approx(immobile_time):
			immobile_timer.wait_time = immobile_time
			immobile_timer.start()
			is_immobile = true
			immobile_time = 0.0

		hurt_ticks.append(Time.get_ticks_msec())
		# Play hurt sound
		play_state_audio(hurt_sound)

		damage_taken.emit(stats.drain_health(damage, damage_type))

		var damage_percentage: int = round(damage / (stats.max_health * 0.3))
		blood_splash_handler.splash_blood(damage_percentage)


func _die() -> void:
	SignalManager.enemy_died.emit()
	print(name, " has died!")
	queue_free()


func _on_immobile_timer_timeout() -> void:
	is_immobile = false
	is_stunned = false
