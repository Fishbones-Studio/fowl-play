extends Node3D

## input name, explanation dict
@export var control_text_dict : Dictionary[StringName, String] = {
	"attack": "Press or hold to attack",
	"switch_weapon": "Press to swap between your melee and ranged weapons",
	"ability_one": "Press for ability one",
	"ability_two": "Press for ability two",
}

@onready var attack_dialogue : DialogueBox = $AttackDialogueBox
@onready var training_dummy : Enemy = $TrainingDummy

func _ready() -> void:
	attack_dialogue.dialogue_folder_path = training_dummy.dialogue_path
	


func _on_player_detector_body_entered(body: Node3D) -> void:
	if body is ChickenPlayer:
		UIManager.remove_ui_by_enum(UIEnums.UI.CONTROL_OVERVIEW)
		SignalManager.add_ui_scene.emit(UIEnums.UI.CONTROL_OVERVIEW, {"control_text_dict" : control_text_dict})
