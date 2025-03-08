## Signal Manager
##
## This script is used to manage signals in the game that are needed in multiple scenes.
## It is an autoload script, meaning it is loaded automatically when the game starts and is accessible from anywhere.
##

extends Node

# Player signals
signal player_transition_state(target_state: PlayerEnums.PlayerStates, information: Dictionary)
