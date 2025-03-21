## Defines base properties that are used across all different weapons/abilities/passives.
class_name BaseResource
extends Resource

# Basic attributes for all resources
@export var name: String 

# Shop Variable
@export var drop_chance: int
@export var cost: int
@export var description: String # Flavour text
@export var type : ItemEnums.ItemTypes # Defines what item slot it uses, extends to other resources

# Visual & UI Elements
@export var icon: Texture  # The icon for the shop/inventory
