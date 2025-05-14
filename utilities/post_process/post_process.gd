class_name PostProcess extends CanvasLayer

@export var shader_steps: Dictionary[int, PostProcessShaderStep] = {}
@export var default_step := 2

## Using a subviewport, so we can exclude objects from the shader
@onready var color_rect: ColorRect = $ColorRect

func _ready():
	_update_shader_params()
	
	# Conneting update signals
	get_viewport().size_changed.connect(_update_shader_params)
	SignalManager.graphics_settings_changed.connect(_update_shader_params)

	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_shader_params():
	var viewport_size = get_viewport().size
	var pp_shader_material: ShaderMaterial = color_rect.material as ShaderMaterial
	if pp_shader_material:
		pp_shader_material.set_shader_parameter("screen_size", viewport_size)
	_apply_saved_variation(pp_shader_material)

func _apply_saved_variation(pp_shader_material: ShaderMaterial) -> void:
	var step : int = int(SettingsManager.get_setting("graphics", "pp_shader", default_step))

	if !shader_steps.has(step): # Check if the step exists in the dictionary
		printerr("PostProcess: Shader step %d not found in dictionary." % step)
		color_rect.hide()
		return

	var shader_resource: PostProcessShaderStep = shader_steps[step]

	if !shader_resource.use_shader:
		push_warning("Disabling Shader")
		color_rect.hide()
		return

	color_rect.show()

	# Apply the resource items to the shader
	if pp_shader_material:
		pp_shader_material.set_shader_parameter("colors", shader_resource.colors)
		pp_shader_material.set_shader_parameter("dither_size", shader_resource.dither_size)
		pp_shader_material.set_shader_parameter("dither_shift", shader_resource.dither_shift)
		pp_shader_material.set_shader_parameter("dither_strength", shader_resource.dither_strength)
		pp_shader_material.set_shader_parameter("dither_hue_shift", shader_resource.dither_hue_shift)
		pp_shader_material.set_shader_parameter("alpha", shader_resource.alpha)
		pp_shader_material.set_shader_parameter("scale", shader_resource.scale)
		pp_shader_material.set_shader_parameter("border_mask", shader_resource.border_mask)
		pp_shader_material.set_shader_parameter("pixel_size", shader_resource.pixel_size)
