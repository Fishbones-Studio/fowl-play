# Cheat Menu Script
extends Control

@onready var input_field_scene: PackedScene = preload("uid://cbaagbd3itbmp")
@onready var content_container: VBoxContainer = %ContentContainer

func _ready() -> void:
	for child in content_container.get_children():
		child.queue_free()
	
	_create_cheat_field("prosperity_eggs", "Prosperity Eggs:", InputValidator.InputType.INTEGER)
	_create_cheat_field("feathers_of_rebirth", "Feathers of Rebirth:", InputValidator.InputType.INTEGER)

func _create_cheat_field(variable_name: String, label_text: String, validation_type: InputValidator.InputType) -> void:
	if not variable_name in GameManager:
		push_error("Missing GameManager property: %s" % variable_name)
		return
	
	var validator: InputValidator = input_field_scene.instantiate()
	var label: Label = validator.get_node("%Label")
	
	if not validator or not label:
		validator.queue_free()
		return
	
	validator.validation_type = validation_type
	label.text = label_text
	validator.set_value(GameManager.get(variable_name))
	
	content_container.add_child(validator)
	label.text = label_text
	validator.set_value(GameManager.get(variable_name))
	validator.value_committed.connect(_on_value_committed.bind(variable_name, validation_type))

func _on_value_committed(new_value: Variant, variable_name: String, _type: InputValidator.InputType) -> void:
	GameManager.set(variable_name, new_value)
	print("Updated %s to %s" % [variable_name, new_value])
