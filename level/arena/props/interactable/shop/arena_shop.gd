# Arena 
extends DialogueBox

@onready var shopkeeper_animation_player : AnimationPlayer = $insighter/AnimationPlayer

func _ready() -> void:
	if shopkeeper_animation_player.has_animation("Idle"):
		shopkeeper_animation_player.play("Idle")
	super()

func interact() -> void:
	if UIEnums.UI.IN_ARENA_SHOP in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.IN_ARENA_SHOP)
