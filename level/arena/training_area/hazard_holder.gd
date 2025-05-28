extends Node3D

@onready var hazard_dialogue : DialogueBox = $HazardDialogueBox
@onready var training_dummy : Enemy = $TrainingDummy

func _ready() -> void:
	hazard_dialogue.dialogue_folder_path = training_dummy.dialogue_path
