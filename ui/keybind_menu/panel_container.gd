extends PanelContainer
@export var label_path : Label
@export var button_path : Button
@export var input_type : SaveEnums.InputType
@onready var action_label: Label = $"../ActionLabel"


func _ready():
	button_path.pressed.connect(_on_input_button_pressed)
	
func _on_input_button_pressed() -> void:
	if SaveManager.is_remapping:
		print("Already remapping a different key")
		return
	
	SaveManager.action_to_remap = action_label.text
	SaveManager.input_type = input_type
	SaveManager.is_remapping = true
	label_path.text = "Press key to bind..."
