## Script to add Visual Layer to all applicable child nodes. 
## *Note*: Not recursive
extends Node3D

# Export the layer *number* (1 to 20) you want to ADD to the children.
@export_range(1, 20) var layer_to_add : int = 1

func _ready():
	# Validate the input layer number just in case
	if layer_to_add < 1 or layer_to_add > 20:
		printerr("Invalid layer_to_add specified: ", layer_to_add, ". Must be between 1 and 20.")
		return

	# Calculate the bitmask value for the specified layer number.
	var layer_bitmask = 1 << (layer_to_add - 1)

	for child in get_children():
		# Check if the child node inherits from VisualInstance3D
		if child is VisualInstance3D:
			var visual_instance = child as VisualInstance3D

			# Use the bitwise OR operator (|) to add the new layer's bit to the existing layers bitmask without removing existing layers.
			visual_instance.layers = visual_instance.layers | layer_bitmask
			print("Node '", visual_instance.name, "' layers set to: ", visual_instance.layers)
