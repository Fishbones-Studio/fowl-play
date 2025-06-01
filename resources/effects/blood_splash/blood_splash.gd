class_name BloodSplash
extends Node3D

@onready var splash: GPUParticles3D = $Splash
@onready var splatter: GPUParticles3D = $Splatter


func set_color(color: Color) -> void:
	splash.material_override.set("shader_parameter/ColorParameter", color)
	splatter.material_override.set("shader_parameter/ColorParameter", color)


func _on_splash_finished() -> void:
	get_parent().remove_child(self)
	queue_free()
