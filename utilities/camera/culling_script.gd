## Script to add Visual Layer to all applicable child nodes,
## optionally recursively.
extends Node3D

# Export the layer *number* (1 to 20) you want to ADD to the children.
@export_range(1, 20) var layer_to_add : int = 1
# If true, applies the layer to all descendants. If false, only direct children.
@export var recursive : bool = false

func _ready() -> void:
	# Validate the input layer number just in case
	if layer_to_add < 1 or layer_to_add > 20:
		printerr(
			"Invalid layer_to_add specified: ",
			layer_to_add,
			". Must be between 1 and 20."
		)
		return

	# Calculate the bitmask value for the specified layer number.
	var layer_bitmask: int = 1 << (layer_to_add - 1)

	if recursive:
		# Start the recursive process from this node's children
		for child in get_children():
			_apply_layer_recursively(child, layer_bitmask)
	else:
		# Apply only to direct children
		for child in get_children():
			_apply_layer_to_node(child, layer_bitmask)


# Helper function to apply the layer to a single node if applicable
func _apply_layer_to_node(node: Node, layer_bitmask: int) -> void:
	# Check if the node inherits from VisualInstance3D
	if node is VisualInstance3D:
		var visual_instance: VisualInstance3D = node as VisualInstance3D
		# Use the bitwise OR operator (|) to add the new layer's bit
		visual_instance.layers = visual_instance.layers | layer_bitmask


# Recursive function to apply the layer to a node and all its descendants
func _apply_layer_recursively(node: Node, layer_bitmask: int) -> void:
	# Apply the layer to the current node first
	_apply_layer_to_node(node, layer_bitmask)

	# Then, recurse into this node's children
	for child in node.get_children():
		_apply_layer_recursively(child, layer_bitmask)
