## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D


@export var green_color = Color.GREEN
@export var orange_color = Color.YELLOW
@export var red_color = Color.RED
@export var max_health: int = 100

const CORNER_RADIUS = 6

var health: int

@onready var damage_label: Marker3D = $Marker3D
@onready var health_bar_node: HealthBar = $SubViewport/HealthBar


func _ready() -> void:
	health = max_health
	_setup_health_bar()
	_update_health_bar_appearance() 
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()
	pass


## Private Methods
func _setup_health_bar() -> void:
	if is_instance_valid(health_bar_node):
		health_bar_node.init_health(max_health, health)
	else:
		printerr("Error: HealthBar node not found within the SubViewport.")


func _update_health_bar() -> void:
	if is_instance_valid(health_bar_node):
		health_bar_node.health = health 
		_update_health_bar_appearance() 


func _update_health_bar_appearance() -> void:
	if is_instance_valid(health_bar_node):
		var health_percentage: float = float(health) / max_health
		var current_color: Color

		if health_percentage > 0.66:
			current_color = green_color
		elif health_percentage > 0.33:
			current_color = orange_color
		else:
			current_color = red_color

		health_bar_node.change_healthbar_appearance(current_color, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS)


func _take_damage(target: PhysicsBody3D, damage: int) -> void:
	if target == self:
		health -= damage
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

		if health <= 0:
			die()


func die() -> void:
	print("Enemy died!")
	queue_free()
