## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D

@export var max_health: int = 100
var health: int

@onready var damage_label: Marker3D = $Marker3D
@onready var health_bar_sprite: Sprite3D = $Sprite3D
@onready var health_bar_viewport: SubViewport = $SubViewport
@onready var health_bar_progress: ProgressBar = $SubViewport/ProgressBar


func _ready() -> void:
	health = max_health
	if health_bar_progress == null:
		printerr("Error: health_bar_progress is null! Check your node paths.")
	else:
		_update_health_bar()
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()


## Private Methods
func _update_health_bar() -> void:
	if is_instance_valid(health_bar_progress):
		health_bar_progress.max_value = max_health
		health_bar_progress.value = health
	else:
		print("Error: health_bar_progress is not valid!")


## Public Methods
func _take_damage(target: PhysicsBody3D, damage: int) -> void:
	if target == self:
		health -= damage
		_update_health_bar()

		var damage_popup: Node3D = preload("uid://b6cnb1t5cixqj").instantiate()
		get_parent().add_child(damage_popup)

		var spawn_position: Vector3 = damage_label.global_position + Vector3(
			randf_range(-damage_popup.horizontal_spread, damage_popup.horizontal_spread),
			randf_range(0, damage_popup.vertical_variance),
			randf_range(-damage_popup.depth_offset, damage_popup.depth_offset)
		)

		damage_popup.global_position = spawn_position
		damage_popup.display_damage(damage)

	if health <= 0:
		die()


func die() -> void:
	print("Enemy died!")
	queue_free()
