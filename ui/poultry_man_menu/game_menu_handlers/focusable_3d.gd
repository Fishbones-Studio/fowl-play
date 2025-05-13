class_name Focusable3D
extends Area3D

signal focused
signal unfocused
signal pressed

# Highlight Settings
@export var highlight_scale_factor: float = 1.1
@export var highlight_color: Color = Color.YELLOW

var original_scale: Vector3
var original_label_color: Color
var is_focused: bool = false

@onready var label: Label3D = _find_label()


func _ready() -> void:
	original_scale = scale
	if label:
		original_label_color = label.modulate
	
	# Connect Area3D signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func _find_label() -> Label3D:
	for child in get_children():
		if child is Label3D:
			return child
		var found = child._find_label() if child.has_method("_find_label") else null
		if found:
			return found
	return null


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

	is_focused = true
	scale = original_scale * highlight_scale_factor
	if label:
		label.modulate = highlight_color
	emit_signal("focused")


func unfocus() -> void:
	if not is_focused:
		return

	is_focused = false
	scale = original_scale
	if label:
		label.modulate = original_label_color
	emit_signal("unfocused")


func press() -> void:
	emit_signal("pressed")
