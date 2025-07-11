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
var _original_state_volume: float
var _original_interval_volume: float

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
@onready var hurt_audio_player: AudioStreamPlayer3D = %HurtAudioPlayer


func _ready() -> void:
	if not stats:
		push_error("Enemy stats resource is not assigned! Please assign a LivingEntityStats resource to the enemy.")
		return

	if hurt_sound:
		hurt_audio_player.stream = hurt_sound
	else:
		push_warning("No enemy hurt sound set")

	stats.init()
	health_bar.init_health(stats.max_health, stats.current_health)
	enemy_name_label.text = name_label_template_string % stats.name.capitalize()

	# Store original volumes
	_original_state_volume = state_audio_player.volume_db
	_original_interval_volume = interval_audio_player.volume_db

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


func play_state_audio(audio_stream: AudioStream, stop_interval: bool = true) -> void:
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


func _on_state_audio_finished(resume_interval: bool = true) -> void:
	if resume_interval:
		# Resume interval timer
		interval_audio_player.random_player.timer.start()


func play_hurt_audio() -> void:
	if not hurt_sound:
		return

	# Mute interval audio player
	interval_audio_player.volume_db = -80.0  # Effectively mute

	# Lower state audio player volume
	state_audio_player.volume_db = _original_state_volume - 12.0  # Lower by 12dB

	# Play hurt sound
	hurt_audio_player.stream = hurt_sound
	hurt_audio_player.play()

	# Connect to finished signal to restore volumes
	if not hurt_audio_player.finished.is_connected(_on_hurt_audio_finished):
		hurt_audio_player.finished.connect(_on_hurt_audio_finished, CONNECT_ONE_SHOT)


func _on_hurt_audio_finished() -> void:
	# Restore original volumes
	interval_audio_player.volume_db = _original_interval_volume
	state_audio_player.volume_db = _original_state_volume


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

		# Play hurt sound using dedicated hurt audio player
		play_hurt_audio()

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
