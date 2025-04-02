class_name MeleeWeapon
extends Node3D

@export var animation_player: AnimationPlayer
@export var current_weapon: MeleeWeaponResource

@onready var hit_area: Area3D = $HitArea


func _ready() -> void:
	# connect a signal to body entering the hit_area
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	# connect a signal to body exiting the hit_area
	hit_area.body_exited.connect(_on_hit_area_body_exited)


func _on_hit_area_body_entered(body: Node) -> void:
	if body is PhysicsBody3D:
		SignalManager.weapon_hit_area_body_entered.emit(body)


func _on_hit_area_body_exited(body: Node) -> void:
	if body is PhysicsBody3D:
		SignalManager.weapon_hit_area_body_exited.emit(body)
