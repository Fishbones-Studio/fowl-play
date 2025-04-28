class_name MeleeWeapon
extends Node3D

@export var animation_player: AnimationPlayer
@export var current_weapon: MeleeWeaponResource

@onready var hit_area: Area3D = $HitArea
