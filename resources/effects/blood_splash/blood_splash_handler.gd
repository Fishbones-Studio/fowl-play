class_name BloodSplashHandler
extends Node3D

@export_flags_3d_physics var layer: int ## For now, has no use.
@export var color: Color = Color.RED

@onready var blood_splash_resource: PackedScene = preload("uid://db55kjv7kn4oc")


func splash_blood(amount: int, is_percentage: bool = true) -> void:
		var blood: BloodSplash = blood_splash_resource.instantiate()
		add_child(blood)

		var splash_amount: int = blood.splash.amount
		if is_percentage: splash_amount *= amount
		blood.set_color(color)
		blood.splash.amount = max(10, splash_amount)
		blood.splash.emitting = true
