class_name InputValidator 
extends ContentItem

signal value_committed(new_value: Variant)

enum InputType { INTEGER, TEXT, FLOAT }

@export var validation_type: InputType = InputType.TEXT:
	set(value):
		validation_type = value
		_validate_text(last_valid_text)

@export var default_value: String = ""

var last_valid_text: String = default_value
var is_validating: bool = false
var last_caret_column: int = 0

@onready var input_field: TextEdit = %InputField
@onready var label : Label = %Label
@onready var panel: Panel = $MarginContainer2/Panel


func _ready() -> void:
	input_field.text_changed.connect(_on_text_changed)
	last_valid_text = default_value if _is_valid(default_value) else _fallback_value()
	input_field.text = last_valid_text


func set_label_text(text: String) -> void:
	if label:
		label.text = text
	else:
		push_error("Label node not found. Ensure the scene structure is correct.")


func _fallback_value() -> String:
	match validation_type:
		InputType.INTEGER: return "0"
		InputType.FLOAT: return "0.0"
		_: return ""


func _is_valid(text: String) -> bool:
	match validation_type:
		InputType.INTEGER: return text.is_valid_int() and text.to_int() >= 0
		InputType.FLOAT: return text.is_valid_float()
		_: return true


func _validate_text(text: String) -> void:
	if not input_field or is_validating:
		return

	is_validating = true

	# Store current cursor position before any changes
	var current_caret_column: int = input_field.get_caret_column()

	if not _is_valid(text):
		# Restore last valid text but keep cursor near where user was typing
		input_field.text = last_valid_text
		input_field.set_caret_column(min(current_caret_column, last_valid_text.length()))
	else:
		last_valid_text = text

		var converted_value: Variant
		match validation_type:
			InputType.INTEGER:
				converted_value = text.to_int()
			InputType.FLOAT:
				converted_value = text.to_float()
			_:
				converted_value = text

		value_committed.emit(converted_value)

	is_validating = false
	call_deferred("_ensure_focus")


func _ensure_focus() -> void:
	if input_field.has_focus():
		input_field.grab_focus()


func set_value(value: Variant) -> void:
	last_valid_text = str(value)
	if input_field:
		input_field.text = last_valid_text


func _on_text_changed() -> void:
	_validate_text(input_field.text)


func _on_focus_entered() -> void:
	input_field.grab_focus()


func _on_input_field_focus_entered() -> void:
	_set_neighbors_for(input_field)
	_toggle_active(panel, true)


func _on_input_field_focus_exited() -> void:
	_validate_text(input_field.text)
	_toggle_active(panel, false)
