class_name CustomLayerLabel3D
extends Label3D

@export_range(1, 20) var visual_layer: int = 3

# TODO: doesnt work anymore

func _ready() -> void:
	visual_layer = 1 << (visual_layer - 1)
	print("Visual layer: %d" % visual_layer)
