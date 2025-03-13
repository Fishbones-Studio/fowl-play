extends Label

@onready var player: ChickenPlayer = $"../../../Player"


func _process(_delta):
	text = "Player location: %v" % player.global_position
