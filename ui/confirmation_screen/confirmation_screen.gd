class_name ConfirmationScreen
extends UserInterface

@onready var title: Label = %TitleLabel
@onready var container: HBoxContainer = %ConfirmationContentItem
@onready var description: RichTextLabel = %DescriptionLabel
@onready var cancel_button: Button = %CancelButton
@onready var confirm_button: Button = %ConfirmButton


func close_ui() -> void:
	UIManager.remove_ui(self)
	SignalManager.focus_lost.emit()


func on_cancel_button_pressed() -> void:
	close_ui()


func on_confirm_button_pressed() -> void:
	pass


func _on_visibility_changed() -> void:
	if visible:
		await get_tree().process_frame
		cancel_button.grab_focus()
