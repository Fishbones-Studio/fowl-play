## Signal Manager
##
## This script is used to manage signals in the game that are needed in multiple scenes.
## It is an autoload script, meaning it is loaded automatically when the game starts and is accessible from anywhere.
##

extends Node

# Player signals
signal player_transition_state(target_state: PlayerEnums.PlayerStates, information: Dictionary)
signal init_health(max_health: int, health: int)
signal hurt_player(damage: int)
signal init_stamina(max_stamina: float, stamina: float)
# Loader signals
signal switch_ui_scene(scene_path: String) ## This signal is used to switch the UI scene, replacing all current
signal add_ui_scene(scene_path: String) ## This signal is used to add an (additional) UI scene
signal switch_game_scene(scenscene_pathe: String) ## This signal is used to switch the game scene, replacing all current
signal add_game_scene(scene_path: String) ## This signal is used to add an (additional) game scene
