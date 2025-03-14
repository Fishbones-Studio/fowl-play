extends Node

var chicken_player : ChickenPlayer = null
var prosperity_eggs = 900
var feathers_of_rebirth: int


func update_prosperity_eggs(amount: int):
	prosperity_eggs += amount
	print("Updated Prosperity Eggs : ",  prosperity_eggs)
	
func update_feathers_of_rebirth(amount: int):
	feathers_of_rebirth += amount
	print("Updates feathers of rebirth: ", feathers_of_rebirth)
	
