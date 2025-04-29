extends MeleeWeapon

func _ready() -> void:
	if GameManager.chicken_player:
		animation_player = GameManager.chicken_player.animation_player
	else: 
		print("No chicken player")
