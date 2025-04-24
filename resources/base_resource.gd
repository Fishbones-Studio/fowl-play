## Defines base properties that are used across all different weapons/abilities/passives.
class_name BaseResource
extends Resource

# Basic attributes for all resources
@export var name: String
# Shop Variable
@export var drop_chance: int
@export var cost: int
@export var currency_type: CurrencyEnums.CurrencyTypes
@export_multiline var description: String = "PlaceHolder" # Flavour text

# Visual & UI Elements
@export var icon: Texture  # The icon for the shop/inventory
@export var model_uid: String # The uid of the model, for saving and loading purpouses

var type: ItemEnums.ItemTypes ## Defines what item slot it uses, extends to other resources. Set in the child class
var type_max_owned_amount: int = 1 ## How many of this item type the player is allowed to have. NOTE: Only overwrite in _init. in resources directly extending BaseResource


# Abstract method
func get_modifier_string() -> Array[String]:
	printerr("get_modifier_string() should be overwritten in child class")
	return []
