## Signal Manager
##
## This script is used to manage signals in the game that are needed in multiple scenes.
## It is an autoload script, meaning it is loaded automatically when the game starts and is accessible from anywhere.
extends Node

# Player signals
signal player_transition_state(target_state: PlayerEnums.PlayerStates, information: Dictionary)
signal init_health(max_health: int, health: int)
signal init_stamina(max_stamina: float, stamina: float)
signal player_stats_changed(stats: LivingEntityStats)

# UI signals
signal player_hurt
signal player_heal
signal deactivate_item_slot(item: BaseResource)
signal activate_item_slot(item: BaseResource)
signal ui_disabled(previous_ui: Control)
signal cooldown_item_slot(item: BaseResource, cooldown: float, create_tween: bool)

# Loader signals
signal switch_ui_scene(scene_path: UIEnums.UI, params: Dictionary) ## This signal is used to switch the UI scene, replacing all current
signal add_ui_scene(scene_path: UIEnums.UI, params: Dictionary) ## This signal is used to add an (additional) UI scene
signal switch_game_scene(scene_path: String) ## This signal is used to switch the game scene, replacing all current
signal add_game_scene(scene_path: String) ## This signal is used to add an (additional) game scene
signal loading_progress_updated(progress: float)  # 0.0 to 1.0
signal loading_screen_started
signal loading_screen_finished

# Enemy signals
signal enemy_transition_state(target_state: EnemyEnums.EnemyStates, information: Dictionary)
signal enemy_died

# Weapon signals
signal weapon_hit_area_body_entered(body: PhysicsBody3D)
signal weapon_hit_area_body_exited(body: PhysicsBody3D)
signal weapon_hit_target(target: PhysicsBody3D, damage: float, type: DamageEnums.DamageTypes)

# Shop signals
signal preview_shop_item(item: BaseResource)
signal upgrades_shop_refreshed
signal purchase_completed

# Round signals
signal start_next_round # to trigger the next round

## Dictionary to store cooldowns for signals
var _cooldowns: Dictionary[StringName, int] = {}


## Throthle function for signals, to prevent spamming
## This function ignores the signal if it is called before the cooldown time has passed
func emit_throttled(signal_name: StringName, args: Array = [], cooldown: float = 0.5) -> void:
	var now: int = Time.get_ticks_msec()
	if now < _cooldowns.get(signal_name, 0):
		return

	_cooldowns[signal_name] = now + int(cooldown * 1000)
	# callv destructures the array and passes it as arguments
	callv("emit_signal", [signal_name] + args)
