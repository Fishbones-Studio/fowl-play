## This autoload manages the save system for the game.
##
## It handles saving and loading input settings, as well as settings
extends Node

# Input remapping 
# Signal would not work here, sine signal order is not guaranteed, which can cause multiple input buttons to be pressed at the same time or other bugs
var is_remapping: bool      = false
var input_type: SaveEnums.InputType
var action_to_remap: String = ""
