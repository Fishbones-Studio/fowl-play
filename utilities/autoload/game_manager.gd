extends Node

var chicken_player: ChickenPlayer = null
var prosperity_eggs: int
var feathers_of_rebirth: int


func reset_game() -> void:
	prosperity_eggs = 0
	feathers_of_rebirth = 0
	Inventory.reset_inventory()


func update_prosperity_eggs(amount: int) -> void:
	prosperity_eggs += amount
	print("Updated Prosperity Eggs : ", prosperity_eggs)


func update_feathers_of_rebirth(amount: int) -> void:
	feathers_of_rebirth += amount
	print("Updates feathers of rebirth: ", feathers_of_rebirth)
