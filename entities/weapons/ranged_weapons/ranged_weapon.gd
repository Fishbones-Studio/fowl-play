class_name RangedWeapon
extends Node3D

@export var animation_player: AnimationPlayer
@export var current_weapon: RangedWeaponResource

@onready var handler : RangedWeaponHandler = $RangedWeaponHandler
