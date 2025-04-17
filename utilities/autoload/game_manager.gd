extends Node

signal prosperity_eggs_changed(new_value : int)
signal feathers_of_rebirth_changed(new_value : int)


var chicken_player: ChickenPlayer = null
var prosperity_eggs: int :
	set(value):
		prosperity_eggs = value
		Inventory.inventory_data.prosperity_eggs = value
		prosperity_eggs_changed.emit(value)
var feathers_of_rebirth: int:
	set(value):
		feathers_of_rebirth = value
		Inventory.inventory_data.prosperity_eggs = value
		feathers_of_rebirth_changed.emit(value)

var current_round: int

func reset_game() -> void:
	Inventory.reset_inventory()


func update_prosperity_eggs(amount: int) -> void:
	prosperity_eggs += amount
	print("Updated Prosperity Eggs : ", prosperity_eggs)


func update_feathers_of_rebirth(amount: int) -> void:
	feathers_of_rebirth += amount
	print("Updates feathers of rebirth: ", feathers_of_rebirth)
