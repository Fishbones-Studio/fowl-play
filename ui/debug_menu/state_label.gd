extends Label

func _ready():
	SignalManager.player_transition_state.connect(_on_player_state_transition)
	
func _on_player_state_transition(next_state : PlayerEnums.PlayerStates, information : Dictionary):
	text = "State: %s \n Additional information: %s" % [[PlayerEnums.PlayerStates.keys()[next_state]] ,  str(information)]
