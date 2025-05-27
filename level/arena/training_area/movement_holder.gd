extends Node3D

@onready var movement_dialogue : DialogueBox = $MovementTrainingDummy/MovementDialogueBox
@onready var training_dummy : Enemy = $MovementTrainingDummy

func _ready() -> void:
	movement_dialogue.dialogue_folder_path = training_dummy.dialogue_path
