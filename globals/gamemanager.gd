extends Node

var prosperity_eggs = 900
var feathers_of_rebirth: int


func Update_ProsperityEggs(amount: int):
	prosperity_eggs += amount
	print("Updated Prosperity Eggs : ",  prosperity_eggs)
	
func Update_FeathersOfRebirth(amount: int):
	feathers_of_rebirth += amount
	print("Updates feathers of rebirth: ", feathers_of_rebirth)
	
