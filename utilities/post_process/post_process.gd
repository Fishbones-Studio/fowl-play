class_name PostProcess extends CanvasLayer

## Using a subviewport, so we can exclude objects from the shader
@onready var color_rect : ColorRect = $ColorRect

func _ready():
	_update_shader_params()
	get_viewport().size_changed.connect(_update_shader_params)
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_shader_params():
	var viewport_size = get_viewport().size
	var pp_shader_material: ShaderMaterial = color_rect.material as ShaderMaterial
	pp_shader_material.set_shader_parameter("screen_size", viewport_size)
	color_rect.size = viewport_size
