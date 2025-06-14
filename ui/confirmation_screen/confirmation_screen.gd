class_name ConfirmationScreen
extends Control

@onready var title: Label = %TitleLabel
@onready var container: HBoxContainer = %ConfirmationContentItem
@onready var description: RichTextLabel = %DescriptionLabel
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton

func _ready() -> void:
	if cancel_button:
		cancel_button.grab_focus()
		
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ):
		on_cancel_button_pressed()
		UIManager.get_viewport().set_input_as_handled()

func close_ui() -> void:
	UIManager.remove_ui(self)
	SignalManager.focus_lost.emit()


func on_cancel_button_pressed() -> void:
	close_ui()


func on_confirm_button_pressed() -> void:
	close_ui()


func _on_visibility_changed() -> void:
	if visible && cancel_button:
		cancel_button.grab_focus()
