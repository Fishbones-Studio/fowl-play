class_name LayerSubViewPort
extends SubViewport

var active_camera: Camera3D = null:
	set(value):
		active_camera = value
		if active_camera:
			camera.global_transform = active_camera.global_transform

@onready var camera: Camera3D = $ViewportCamera


func _process(_delta):
	if active_camera:
		camera.global_transform = active_camera.global_transform
