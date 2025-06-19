class_name RemapPanel
extends Panel

@export var button: Button
@export var container: HBoxContainer
@export var input_type : SaveEnums.InputType

var action_to_remap : String


func _ready():
	button.pivot_offset = button.size / 2.0
	if container: 
		container.pivot_offset = container.size / 2.0
		if button.visible: button.visible = false
		if not container.visible: container.visible = true

	button.button_up.connect(_on_input_button_up)
	button.focus_entered.connect(_on_button_focus_entered)
	button.focus_exited.connect(_on_button_focus_exited)


func _on_input_button_up() -> void:
	if SettingsManager.is_remapping:
		print("Already remapping a different key")
		return

	print("The set remapping action: %s" % action_to_remap )
	SettingsManager.action_to_remap = action_to_remap
	SettingsManager.input_type = input_type
	SettingsManager.is_remapping = true
	if container: container.visible = false
	if not button.visible: button.visible = true
	button.text = "Press any key..."


func _on_button_focus_entered() -> void:
	TweenManager.create_scale_tween(null, button, Vector2(1.05, 1.05))
	if container:
		TweenManager.create_scale_tween(null, container, Vector2(1.05, 1.05))


func _on_button_focus_exited() -> void:
	TweenManager.create_scale_tween(null, button, Vector2(1.0, 1.0))
	if container:
		TweenManager.create_scale_tween(null, container, Vector2(1.0, 1.0))
