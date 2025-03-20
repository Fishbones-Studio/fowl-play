extends Node
#Autoload s	cript to manage all items in the game. Will excist of a dict of all items and a function to get a random item.

var items = [
	#Ranged_Weapons
	load("res://resources/ranged_weapon_resources/crossbow.tres"),
	load("res://resources/ranged_weapon_resources/flamethrower.tres"),
	load("res://resources/ranged_weapon_resources/lazer_eyes.tres"),
	load("res://resources/ranged_weapon_resources/minigun.tres"),
	load("res://resources/ranged_weapon_resources/musket.tres"),
	load("res://resources/ranged_weapon_resources/pistol.tres"),
	load("res://resources/ranged_weapon_resources/revolver.tres"),
	load("res://resources/ranged_weapon_resources/slingshot.tres"),
	load("res://resources/ranged_weapon_resources/sniper.tres"),
	#Melee_Weapons
	load("res://resources/weapon_resources/axe.tres"),
	load("res://resources/weapon_resources/bone.tres"),
	load("res://resources/weapon_resources/flipflops.tres"),
	load("res://resources/weapon_resources/frying_pan.tres"),
	load("res://resources/weapon_resources/hammer.tres"),
	load("res://resources/weapon_resources/knife.tres"),
	load("res://resources/weapon_resources/leek.tres"),
	load("res://resources/weapon_resources/phasesaber.tres"),
	load("res://resources/weapon_resources/stick.tres"),
	load("res://resources/weapon_resources/sword.tres"),	
]
const ITEM_ENUMS = preload("res://utilities/enums/item_enums.gd")

func _ready() -> void:
	for item in items:
		print("Loaded item: ", item.name, " with type: ", item_type_to_string(item.type))
#Function to get a random item from the list above
func get_random_item():
	var total_drop_chance = 0
	for item in items:
		total_drop_chance += item.drop_chance
		
	var roll = randi() % total_drop_chance
	var cumulative = 0
	
	#Get a random rarity accordingly to the chances
	for item in items:
		cumulative += item.drop_chance

		if roll < cumulative:
			return item
			

# Helper function to convert the enum to a readable string
func item_type_to_string(item_type: int) -> String:
	match item_type:
		ITEM_ENUMS.ItemTypes.WEAPON:
			return "Weapon"
		ITEM_ENUMS.ItemTypes.RANGED_WEAPON:
			return "Ranged Weapon"
		ITEM_ENUMS.ItemTypes.PASSIVE:
			return "Passive"
		ITEM_ENUMS.ItemTypes.ABILITY:
			return "Ability"
	return "Unknown"  # Fallback if the type is not recognized	
