extends Node3D

@onready var attack_dialogue : DialogueBox = %AttackDialogueBox
@onready var training_dummy : Enemy = $TrainingDummy

func _ready() -> void:
	attack_dialogue.dialogue_folder_path = training_dummy.dialogue_path
