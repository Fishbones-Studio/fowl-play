class_name Pixelate extends Control

@onready var pixelate_shader: ColorRect = %PixelateShader

func _ready():
	_update_shader_params()
	get_viewport().size_changed.connect(_update_shader_params)
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_shader_params():
	var shader_material: ShaderMaterial = pixelate_shader.material as ShaderMaterial
	shader_material.set_shader_parameter("screen_size", get_viewport().size)
