class_name Ability
extends Node3D

@export var current_ability: AbilityResource

var ability_holder: CharacterBody3D

var on_cooldown: bool:
	get:
		return not cooldown_timer.is_stopped()

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	if not current_ability:
		push_warning("Ability resource not set: ", current_ability)
		return

	cooldown_timer.wait_time = current_ability.cooldown


func activate() -> void:
	pass


func _on_cooldown_timer_timeout() -> void:
	pass


func _toggle_collision_masks(toggle: bool, hit_area: Area3D, ignore_collision_layer: bool = false) -> void:
	if ability_holder.collision_layer == 2 or ignore_collision_layer: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4 or ignore_collision_layer: # Enemy
		hit_area.set_collision_mask_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle)  # World
