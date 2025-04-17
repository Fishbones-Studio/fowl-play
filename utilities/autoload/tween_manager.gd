################################################################################
## Autoload to manage tween creation and lifetime.
##
################################################################################
extends Node

const DEFAULT_DURATION: float = 0.2
const DEFAULT_TRANSITION: Tween.TransitionType = Tween.TRANS_CUBIC
const DEFAULT_EASE: Tween.EaseType = Tween.EASE_OUT


func create_scale_tween(
	tween: Tween,
	node: Node,
	scale: Variant,
	duration: float = DEFAULT_DURATION,
	transition: Tween.TransitionType = DEFAULT_TRANSITION,
	tween_ease: Tween.EaseType = DEFAULT_EASE
) -> Tween:
	assert(scale is Vector2 or scale is Vector3,
	"Scale must be a Vector2 or Vector3")

	if not tween: tween = node.create_tween()
	tween.tween_property(node, "scale", scale, duration)\
	.set_trans(transition)\
	.set_ease(tween_ease)

	return tween


func create_move_tween(
	tween: Tween,
	node: Node,
	axis: String,
	distance: float,
	duration: float = DEFAULT_DURATION,
	transition: Tween.TransitionType = DEFAULT_TRANSITION,
	tween_ease: Tween.EaseType = DEFAULT_EASE
) -> Tween:
	assert(node != null, "Target node cannot be null")
	assert(axis.to_lower() in ["x", "y", "z"], "Axis must be 'x', 'y', or 'z'")

	var property := "position:%s" % axis.to_lower()

	if not tween: tween = node.create_tween()
	tween.tween_property(node, property, distance, duration)\
	.set_trans(transition)\
	.set_ease(tween_ease)
	return tween


func create_size_tween(
	tween: Tween,
	node: Node,
	axis: String,
	target_size: float,
	duration: float = DEFAULT_DURATION,
	transition: Tween.TransitionType = DEFAULT_TRANSITION,
	ease_type: Tween.EaseType = DEFAULT_EASE
) -> Tween:
	assert(axis.to_lower() in ["x", "y"], "Axis must be 'x' or 'y'")
	if not node or not node.is_inside_tree():
		push_error("Cannot create size tween: Node is null or not in tree.")
		return null

	var property := "size:%s" % axis.to_lower()
	if not tween:
		push_error("Failed to create size tween instance.")
		return null

	tween.tween_property(node, property, target_size, duration)\
	.set_trans(transition)\
	.set_ease(ease_type)
	return tween
