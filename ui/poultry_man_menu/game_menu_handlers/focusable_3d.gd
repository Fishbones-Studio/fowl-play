################################################################################
## A 3D object that can receive focus and input events from mouse interaction.
##
## This class provides visual feedback when hovered (focus) and handles click
## events. It can optionally affect a target object (focusable_object) and a 
## Label3D with highlight effects.
## Very Crack.
################################################################################
class_name Focusable3D
extends CollisionObject3D

signal focused
signal unfocused
signal pressed

@export var focusable_objects: Array[Node3D] = [] # Crack
@export var label: Label3D
@export var highlight_scale_factor: float = 1.1
@export var highlight_color: Color = Color("c3d76c")
@export var outline_color: Color = Color.BLACK
@export var outline_size: float = 50
@export var index: int = 0

var object_scales: Dictionary[Node3D, Vector3] = {}
var prev_label_color: Color = Color("c3d76c")
var prev_label_outline_color: Color = Color("282b38")
var prev_label_outline_size: float = 12
var is_focused: bool = false


func _ready() -> void:
	for item in focusable_objects:
		if item == null: continue
		object_scales[item] = item.scale

	if label:
		prev_label_color = label.modulate
		prev_label_outline_size = label.outline_size

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
		var tween: Tween = TweenManager.create_scale_tween(
				null,
				item,
				Vector3(object_scales[item] * highlight_scale_factor),
				0.2,
				TweenManager.DEFAULT_TRANSITION,
				Tween.EASE_OUT
			)
		tween.finished.connect(tween.kill)

	is_focused = true

	if label:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(
			func(arr: Array):
				label.modulate = arr[0] # dunno if this works, since it's color but meh
				label.outline_modulate = arr[1] # ditto
				label.outline_size = arr[2],
				[
					prev_label_color,
					prev_label_outline_color,
					prev_label_outline_size,
				],
				[
					highlight_color,
					outline_color,
					outline_size,
				],
				0.1
		)
		tween.finished.connect(tween.kill)

	focused.emit()


func unfocus() -> void:
	if not is_focused:
		return

	for item in focusable_objects:
		var tween: Tween = TweenManager.create_scale_tween(null,
			item,
			Vector3(object_scales[item]),
			0.2,
			TweenManager.DEFAULT_TRANSITION,
			Tween.EASE_OUT
		)
		tween.finished.connect(tween.kill)

	is_focused = false

	if label:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(
			func(arr: Array):
				label.modulate = arr[0]
				label.outline_modulate = arr[1]
				label.outline_size = arr[2],
				[
					highlight_color,
					outline_color,
					outline_size,
				],
				[
					prev_label_color,
					prev_label_outline_color,
					prev_label_outline_size,
				],
				0.1
		)
		tween.finished.connect(tween.kill)

	unfocused.emit()


func press() -> void:
	pressed.emit()
