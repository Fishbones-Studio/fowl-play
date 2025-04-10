## Enemy: A basic enemy that can take damage and die.
class_name Hennifer_Chicken
extends Enemy

@export var hennifer_stats: LivingEntityStats

func _ready() -> void:
	if hennifer_stats != null:
		stats = hennifer_stats 
		stats.init()
	else:
		printerr("err: hennifer stats resource is null")
	super._ready()
