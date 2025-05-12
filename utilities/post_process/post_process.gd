class_name PostProcess extends Control

@onready var pixelate_shader: SubViewportContainer = %PostProcessShader
## Using a subviewport, so we can exclude objects from the shader
@onready var subviewport : SubViewport = %SubViewport

func _ready():
	_update_shader_params()
	get_viewport().size_changed.connect(_update_shader_params)
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_shader_params():
	var viewport_size = get_viewport().size
	var shader_material: ShaderMaterial = pixelate_shader.material as ShaderMaterial
	shader_material.set_shader_parameter("screen_size", viewport_size)
	subviewport.size = viewport_size
