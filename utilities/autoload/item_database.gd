extends Node
#Autoload s	cript to manage all items in the game. Will excist of a dict of all items and a function to get a random item.
enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

var items: Array[Variant] = [
	{"name": "Stick", "rarity": Rarity.COMMON, "type": "Melee", "cost": 100},
	{"name": "Lake", "rarity": Rarity.COMMON, "type": "Melee", "cost": 100},
	{"name": "Flipflops", "rarity": Rarity.COMMON, "type": "Melee", "cost": 100},
	{"name": "Bone", "rarity": Rarity.COMMON, "type": "Melee", "cost": 100},
	{"name": "Hammer", "rarity": Rarity.UNCOMMON, "type": "Melee", "cost": 200},
	{"name": "Knife", "rarity": Rarity.UNCOMMON, "type": "Melee", "cost": 200},
	{"name": "Frying Pan", "rarity": Rarity.UNCOMMON, "type": "Melee", "cost": 200},
	{"name": "Sword", "rarity": Rarity.RARE, "type": "Melee", "cost": 1000},
	{"name": "Axe", "rarity": Rarity.RARE, "type": "Melee", "cost": 1000},
	{"name": "Lightsaber", "rarity": Rarity.RARE, "type": "Melee", "cost": 1000},
	{"name": "Slingshot", "rarity": Rarity.COMMON, "type": "Ranged", "cost": 100},
	{"name": "Crossbow", "rarity": Rarity.COMMON, "type": "Ranged", "cost": 100},
	{"name": "Revolver", "rarity": Rarity.UNCOMMON, "type": "Ranged", "cost": 200},
	{"name": "Pistol", "rarity": Rarity.UNCOMMON, "type": "Ranged", "cost": 200},
	{"name": "Musket", "rarity": Rarity.UNCOMMON, "type": "Ranged", "cost": 200},
	{"name": "Minigun", "rarity": Rarity.RARE, "type": "Ranged", "cost": 1000},
	{"name": "Sniper", "rarity": Rarity.RARE, "type": "Ranged", "cost": 1000},
	{"name": "Lazet eyes", "rarity": Rarity.RARE, "type": "Ranged", "cost": 1000},
	{"name": "Flamethrower", "rarity": Rarity.RARE, "type": "Ranged", "cost": 1000},
	{"name": "Cap", "rarity": Rarity.COMMON, "type": "Passive", "cost": 100},
	{"name": "Flipflops", "rarity": Rarity.COMMON, "type": "Passive", "cost": 100},
	{"name": "Bubblewrap Helmet", "rarity": Rarity.COMMON, "type": "Passive", "cost": 100},
	{"name": "Bubblewrap Boots", "rarity": Rarity.UNCOMMON, "type": "Passive", "cost": 200},
	{"name": "Rollerblades", "rarity": Rarity.RARE, "type": "Passive", "cost": 500},
	{"name": "Jordans", "rarity": Rarity.RARE, "type": "Passive", "cost": 1000},
	{"name": "Helmet", "rarity": Rarity.RARE, "type": "Passive", "cost": 1000},
	{"name": "Mohawk", "rarity": Rarity.RARE, "type": "Passive", "cost": 1000},
	{"name": "Helicoter blades", "rarity": Rarity.COMMON, "type": "Ability", "cost": 1000},
	{"name": "Mechenical butt", "rarity": Rarity.COMMON, "type": "Ability", "cost": 1000},
	{"name": "Chamovlage Mutation", "rarity": Rarity.COMMON, "type": "Ability", "cost": 1000},
	{"name": "Necromancer Mutation", "rarity": Rarity.COMMON, "type": "Ability", "cost": 1000},
	{"name": "Blink Mutation", "rarity": Rarity.COMMON, "type": "Ability", "cost": 1000},
]

# TODO: replace variant with correct resource type

#Function to get a random item from the list above
func get_random_item() -> Variant:
	var rarity_chances: Dictionary = { Rarity.COMMON: 60, Rarity.UNCOMMON: 30, Rarity.RARE: 10}
	var roll: int            = randi() % 100
	var selected_rarity: int = Rarity.COMMON
	var cumulative: int      = 0
	#Get a random rarity accordingly to the chances
	for rarity in rarity_chances.keys():
		cumulative += rarity_chances[rarity]
		if roll < cumulative:
			selected_rarity = rarity
			break
			
	print("Selected rarity:", selected_rarity)
	#List of items that match the rarity
	var filtered_items: Array = items.filter(func(item): return item.rarity == selected_rarity)
			
	#Select item
	if filtered_items.size() > 0:
		var selected_item = filtered_items[randi() % filtered_items.size()]
		print("Selected item:", selected_item["name"]) 
		return selected_item
	else:
		print("No items found for rarity:", selected_rarity)
		return null
		
			
