extends Node

var prosperity_eggs = 900
var feathers_of_rebirth: int


func update_prosperityEggs(amount: int):
	prosperity_eggs += amount
	print("Updated Prosperity Eggs : ",  prosperity_eggs)
	
func update_feathersOfRebirth(amount: int):
	feathers_of_rebirth += amount
	print("Updates feathers of rebirth: ", feathers_of_rebirth)
	
