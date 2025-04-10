class_name IceFox
extends Enemy

@export var ice_fox_stats: LivingEntityStats
@export var ice_fox_high_health_color: Color = Color.BLUE 
@export var ice_fox_medium_health_color: Color = Color.AQUA 
@export var ice_fox_low_health_color: Color = Color.TEAL 

func _ready() -> void:
	if ice_fox_stats != null:
		print("fox called")
		high_health_color = ice_fox_high_health_color
		medium_health_color = ice_fox_medium_health_color
		low_health_color = ice_fox_low_health_color
		stats = ice_fox_stats
		stats.init()
	else:
		printerr("ERROR: ice_fox_stats stats resource is NULL!")
	super._ready()
