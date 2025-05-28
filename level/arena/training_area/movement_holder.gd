extends Node3D

@onready var movement_dialogue : DialogueBox = $MovementTrainingDummy/MovementDialogueBox
@onready var training_dummy : Enemy = $MovementTrainingDummy

## input name, explanation dict
@export var control_text_dict : Dictionary[StringName, String] = {
	"jump": "Press to jump (double jump while in the air), hold to glide",
	"dash": "Press to dash",
	"sprint": "Hold to sprint"
}


func _ready() -> void:
	movement_dialogue.dialogue_folder_path = training_dummy.dialogue_path


func _on_player_detector_body_entered(body: Node3D) -> void:
	if body is ChickenPlayer:
		var control_overview = UIManager.ui_list.get(UIEnums.UI.CONTROL_OVERVIEW)
		if is_instance_valid(control_overview) && control_overview is ControlOverview:
			control_overview.control_text_dict = control_text_dict
			control_overview.visible = true
		else:
			push_warning("Control overview not added yet: movement holder")
			SignalManager.add_ui_scene.emit(UIEnums.UI.CONTROL_OVERVIEW, {"control_text_dict": control_text_dict})


func _on_player_detector_body_exited(body: Node3D) -> void:
	if body is ChickenPlayer:
		var control_overview = UIManager.ui_list.get(UIEnums.UI.CONTROL_OVERVIEW)
		if is_instance_valid(control_overview) && control_overview is ControlOverview:
			control_overview.visible = false
