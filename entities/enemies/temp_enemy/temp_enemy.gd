## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D


@export var high_health_color: Color = Color.GREEN
@export var medium_health_color: Color = Color.YELLOW
@export var low_health_color: Color = Color.RED
@export var stats: LivingEntityStats


const CORNER_RADIUS = 6

@onready var damage_label: Marker3D = $Marker3D
@onready var health_bar_node: HealthBar = $SubViewport/HealthBar


func _ready() -> void:
	print("Enemy _ready() called. Stats resource: ", stats)
	if stats == null:
		printerr("ERROR: Stats resource is NULL!")
	else:
		stats.init()
		_setup_health_bar()
		_update_health_bar_appearance()
		SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _setup_health_bar() -> void:
	if is_instance_valid(health_bar_node):
		health_bar_node.init_health(stats.max_health, stats.current_health)
	else:
		printerr("Error: HealthBar node not found within the SubViewport.")


func _update_health_bar() -> void:
	if is_instance_valid(health_bar_node):
		health_bar_node.health = stats.current_health
		_update_health_bar_appearance()


func _update_health_bar_appearance() -> void:
	if is_instance_valid(health_bar_node):
		var health_percentage: float = float(stats.current_health) / stats.max_health
		var current_color: Color

		if health_percentage > 0.66:
			current_color = high_health_color
		elif health_percentage > 0.33:
			current_color = medium_health_color
		else:
			current_color = low_health_color

		var corner_radius = Vector4(CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS)
		health_bar_node.change_healthbar_appearance(current_color, corner_radius)


func _take_damage(target: PhysicsBody3D, damage: int) -> void:
	if target == self:
		stats.drain_health(damage) 
		_update_health_bar()

		var damage_popup: Node3D = preload("uid://b6cnb1t5cixqj").instantiate()
		var root = get_tree().get_root().get_child(0)
		if is_instance_valid(root):
			root.add_child(damage_popup)
		else:
			printerr("Error: Could not find the root node to add damage popup.")

		var spawn_position: Vector3 = damage_label.global_position + Vector3(
			randf_range(-damage_popup.horizontal_spread, damage_popup.horizontal_spread),
			randf_range(0, damage_popup.vertical_variance),
			randf_range(-damage_popup.depth_offset, damage_popup.depth_offset)
		)

		damage_popup.global_position = spawn_position
		damage_popup.display_damage(damage)

		if stats.current_health <= 0:
			die()


func die() -> void:
	print("Enemy died!")
	queue_free()
