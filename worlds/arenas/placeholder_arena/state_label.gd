extends Label

# THIS SHOULD BE IN UI FOLDER, BUT IS TEMP ANYWAYS

func _ready():
	SignalManager.player_transition_state.connect(_on_player_state_transition)
	
func _on_player_state_transition(next_state : PlayerEnums.PlayerStates):
	text = "State: %s" % [PlayerEnums.PlayerStates.keys()[next_state]]
