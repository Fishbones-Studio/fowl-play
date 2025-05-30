class_name RemapPanel
extends Panel

@export var button: Button
@export var input_type : SaveEnums.InputType

var action_to_remap : String


func _ready():
	button.button_up.connect(_on_input_button_up)


func _on_input_button_up() -> void:
	if SettingsManager.is_remapping:
		print("Already remapping a different key")
		return

	print("The set remapping action: %s" % action_to_remap )
	SettingsManager.action_to_remap = action_to_remap
	SettingsManager.input_type = input_type
	SettingsManager.is_remapping = true
	button.text = "Press any key..."
