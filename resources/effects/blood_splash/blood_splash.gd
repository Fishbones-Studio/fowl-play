class_name BloodSplash
extends Node3D

@onready var splash: GPUParticles3D = $Splash
@onready var splatter: GPUParticles3D = $Splatter


func set_color(color: Color) -> void:
	splash.set_instance_shader_parameter("main_color", color)
	splatter.set_instance_shader_parameter("main_color", color)


func _on_splatter_finished() -> void:
	get_parent().remove_child(self)
	queue_free()
