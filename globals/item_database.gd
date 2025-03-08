extends Node

enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

var items = [
	{"name": "Common Sword", "rarity": Rarity.COMMON, "cost": 100},
	{"name": "Uncommon Sword", "rarity": Rarity.UNCOMMON, "cost": 200},
	{"name": "Rare Sword", "rarity": Rarity.RARE, "cost": 500},
	{"name": "Epic Sword", "rarity": Rarity.EPIC, "cost": 1000},
	{"name": "Legendary Sword", "rarity": Rarity.LEGENDARY, "cost": 5000},
	{"name": "Common Bow", "rarity": Rarity.COMMON, "cost": 100},
	{"name": "Uncommon Bow", "rarity": Rarity.UNCOMMON, "cost": 200},
	{"name": "Rare Bow", "rarity": Rarity.RARE, "cost": 500},
	{"name": "Epic Bow", "rarity": Rarity.EPIC, "cost": 1000},
	{"name": "Legendary Bow", "rarity": Rarity.LEGENDARY, "cost": 5000},
	{"name": "Common Armor", "rarity": Rarity.COMMON, "cost": 100},
	{"name": "Uncommon Armor", "rarity": Rarity.UNCOMMON, "cost": 200},
	{"name": "Rare Armor", "rarity": Rarity.RARE, "cost": 500},
	{"name": "Epic Armor", "rarity": Rarity.EPIC, "cost": 1000},
	{"name": "Legendary Armor", "rarity": Rarity.LEGENDARY, "cost": 5000},
	{"name": "Vial of Mutation", "rarity": Rarity.LEGENDARY, "cost": 5000},
	{"name": "Mechenical Arm", "rarity": Rarity.LEGENDARY, "cost": 5000},
]
#Function to get a random item from the list above
func get_random_item():
	var rarity_chances = { Rarity.COMMON: 50, Rarity.UNCOMMON: 30, Rarity.RARE: 15, Rarity.EPIC: 4, Rarity.LEGENDARY: 1 }
	var roll = randi() % 100
	var selected_rarity = Rarity.COMMON
	var cumulative = 0
	#Get a random rarity accordingly to the chances
	for rarity in rarity_chances.keys():
		cumulative += rarity_chances[rarity]
		if roll < cumulative:
			selected_rarity = rarity
			break
			
	print("Selected rarity:", selected_rarity)
	#List of items that match the rarity
	var filtered_items = items.filter(func(item): return item.rarity == selected_rarity)
			
	#Select item
	if filtered_items.size() > 0:
		var selected_item = filtered_items[randi() % filtered_items.size()]
		print("Selected item:", selected_item["name"])
		return selected_item
		
			
