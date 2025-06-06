# Arena 
extends DialogueBox

@onready var shopkeeper_animation_player : AnimationPlayer = $insighter/AnimationPlayer

func _ready() -> void:
	if shopkeeper_animation_player.has_animation("Idle"):
		shopkeeper_animation_player.play("Idle")
	super()
