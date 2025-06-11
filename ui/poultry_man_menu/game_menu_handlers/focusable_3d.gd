################################################################################
# A 3D object that can receive focus and input events from mouse interaction.
#
# This class provides visual feedback when hovered (focus) and handles click
# events. It can optionally affect a target object (focusable_object) and a 
# Label3D with highlight effects.
# Very Crack.
################################################################################
class_name Focusable3D
extends CollisionObject3D

signal focused
signal unfocused
signal pressed

@export var highlight_scale_factor: float = 1.1
@export var highlight_color: Color = Color.YELLOW
@export var focusable_objects: Array[Node3D] = [] # Crack
@export var label: Label3D
@export var index: int = 0

var object_scales: Dictionary[Node3D, Vector3] = {}
var original_label_color: Color
var is_focused: bool = false


func _ready() -> void:
	for item in focusable_objects:
		object_scales[item] = item.scale

	if label:
		original_label_color = label.modulate

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func _on_mouse_entered() -> void:
	focus()


func _on_mouse_exited() -> void:
	unfocus()


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		press()


func focus() -> void:
	if is_focused:
		return

	for item in focusable_objects:
		TweenManager.create_scale_tween(
			null,
			item,
			Vector3(object_scales[item] * highlight_scale_factor),
			0.2,
			TweenManager.DEFAULT_TRANSITION,
			Tween.EASE_OUT)
		#item.scale = object_scales[item] * highlight_scale_factor

	is_focused = true

	if label:
		label.modulate = highlight_color

	focused.emit()


func unfocus() -> void:
	if not is_focused:
		return

	for item in focusable_objects:
		TweenManager.create_scale_tween(null,
		item,
		Vector3(object_scales[item]),
		0.2,
		TweenManager.DEFAULT_TRANSITION,
		Tween.EASE_OUT)
		#item.scale = object_scales[item]

	is_focused = false

	if label:
		label.modulate = original_label_color

	unfocused.emit()


func press() -> void:
	pressed.emit()
