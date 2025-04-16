class_name RangedWeapon
extends Node3D

@export var animation_player: AnimationPlayer
@export var current_weapon: RangedWeaponResource

var entity_stats: LivingEntityStats:
	get:
		if entity_stats == null:
			push_error("No entity stats set")
		return entity_stats

@onready var handler : RangedWeaponHandler = $RangedWeaponHandler
