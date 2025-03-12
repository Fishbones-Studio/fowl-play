extends Label

func _process(_delta):
	if(GameManager.chicken_player == null):
		text = "Currently no player"
		return

	text = "Player location: %v" % GameManager.chicken_player.global_position
