################################################################################
## Script to manage changing various game variables.
##
## This script handles the cheat settings UI, allowing users to change important
## game values, mainly for testing purposes.
################################################################################
extends Control

signal back_requested

enum ToggleCheats{
	INFINITE_HEALTH,
	INFINITE_DAMAGE
}

@onready var input_field_scene: PackedScene = preload("uid://cbaagbd3itbmp")
@onready var check_button_scene: PackedScene = preload("uid://cukdcvp0jsd4j")
@onready var content_container: VBoxContainer = %ContentContainer


func _ready() -> void:
	for child in content_container.get_children():
		child.queue_free()

	# Create Input Fields
	_create_cheat_field(
		"prosperity_eggs",
		"Prosperity Eggs:",
		InputValidator.InputType.INTEGER
	)
	_create_cheat_field(
		"feathers_of_rebirth",
		"Feathers of Rebirth:",
		InputValidator.InputType.INTEGER
	)

	# Create Checkboxes
	_create_cheat_toggle(ToggleCheats.INFINITE_HEALTH,  GameManager.infinite_health)
	_create_cheat_toggle(ToggleCheats.INFINITE_DAMAGE, GameManager.infinite_damage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		UIManager.get_viewport().set_input_as_handled()

func _create_cheat_field(
	variable_name: String,
	label_text: String,
	validation_type: InputValidator.InputType
) -> void:
	if not variable_name in GameManager:
		push_error("Missing GameManager property: %s" % variable_name)
		return
	
	var validator: InputValidator = input_field_scene.instantiate()

	if not validator:
		push_error("Could not instantiate or find nodes in input_field_scene.")
		return

	validator.validation_type = validation_type
		

	content_container.add_child(validator)
	validator.set_value(GameManager.get(variable_name))

	validator.set_label_text(label_text)
	# Connect signal after adding to scene tree
	validator.value_committed.connect(
		_on_value_committed.bind(variable_name, validation_type)
	)


func _create_cheat_toggle(
	cheat: ToggleCheats, initial_state: bool
) -> void:
	var instance: ContentItemCheckButton = check_button_scene.instantiate()

	if not instance:
		push_error("Could not instantiate check_button_scene.")
		return

	content_container.add_child(instance)

	# converting the enum to string
	var label_text: String = "%s:" % ToggleCheats.keys()[cheat].capitalize()

	instance.set_text(label_text)
	# Set initial state without triggering the signal
	instance.set_pressed_no_signal(initial_state)
	
	# Connect signal after adding to scene tree
	instance.toggled.connect(_on_cheat_toggled.bind(cheat))


func _on_value_committed(new_value: Variant, variable_name: String, _type: InputValidator.InputType) -> void:
	GameManager.set(variable_name, new_value)
	print("Updated %s to %s" % [variable_name, new_value])


func _on_cheat_toggled(is_pressed: bool, cheat: ToggleCheats) -> void:
	print("Cheat '%d' toggled: %s" % [cheat, is_pressed])

	match cheat:
		ToggleCheats.INFINITE_HEALTH:
			GameManager.infinite_health = is_pressed
		ToggleCheats.INFINITE_DAMAGE:
			GameManager.infinite_damage = is_pressed
		_:
			push_warning("Unhandled cheat toggle: %d" % cheat)
