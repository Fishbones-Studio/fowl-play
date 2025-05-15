class_name PostProcessShaderStep extends Resource

@export_group("Global Control")
@export var use_shader : bool = true

@export_group("Color and Dithering")
@export_range(1, 16) var colors: int = 12
@export_range(1, 8) var dither_size: int = 1
@export_range(-0.5, 0.5) var dither_shift: float = 0.1
@export_range(0.0, 1.0) var dither_strength: float = 0.5
@export_range(-3.1416, 3.1416) var dither_hue_shift: float = 0.0

@export_group("Visual Controls")
@export_range(0.0, 1.0) var alpha: float = 1.0
@export_range(1.0, 2.0) var scale: float = 1.0
@export_range(0.0, 5.0) var border_mask: float = 2.0

@export_group("Pixelation")
@export_range(1, 64) var pixel_size: int = 2
