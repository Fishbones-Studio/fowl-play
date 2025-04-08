class_name IceFox
extends CharacterBody3D

@export var stats: LivingEntityStats


func _ready() -> void:
	stats.init()
