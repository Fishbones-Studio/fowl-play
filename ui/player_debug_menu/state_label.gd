extends Label

func _ready():
	SignalManager.player_state_transitioned.connect(_on_player_state_transition)
	pass

func _on_player_state_transition(next_state: PlayerEnums.PlayerStates, information: Dictionary):
	# TODO: when spamming buttons, this ui stays stuck displaying the previous state
	text = "State: %s \nAdditional information: %s" % [[PlayerEnums.PlayerStates.keys()[next_state]], str(information)]
