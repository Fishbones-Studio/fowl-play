extends Node

signal prosperity_eggs_changed(new_value : int)
signal feathers_of_rebirth_changed(new_value : int)


var chicken_player: ChickenPlayer = null
var prosperity_eggs: int :
	set(value):
		print("Setting prosperity eggs to: ", value)
		prosperity_eggs = value
		Inventory.inventory_data.prosperity_eggs = value
		prosperity_eggs_changed.emit(value)
var feathers_of_rebirth: int:
	set(value):
		feathers_of_rebirth = value
		Inventory.inventory_data.prosperity_eggs = value
		feathers_of_rebirth_changed.emit(value)

## Amount of prosperity eggs earned per round. Gets multiplied by the round number
var arena_round_reward : int = 50 
## Amount of prosperity eggs earned for completing the arena (aka the final round)
var arena_completion_reward : int = 200

var current_round: int = 1:
	set(value):
		# If the round progresses, add more prosperity eggs
		if value > current_round:
			prosperity_eggs += arena_round_reward * value
		current_round = value


func reset_game() -> void:
	prosperity_eggs = clamp((100 + current_round * int(arena_round_reward / 2.0)), 125, 200)
	Inventory.reset_inventory()
