## Defines base properties that are used across all different weapons/abilities/passives.
class_name BaseResource
extends Resource

@export_group("General")
@export var name: String
@export_group("Shop")
@export var purchasable := true
@export_range(0, 100, 1) var drop_chance: int
@export var cost: int
@export var currency_type: CurrencyEnums.CurrencyTypes

@export_group("Description")
@export_multiline var description: String = "PlaceHolder" # Flavour text. Should always be displayed in a RichTextLabel with BBCode support
@export_multiline var short_description: String

@export_group("Visual & UI")
@export var icon: Texture  # The icon for the shop/inventory
@export var model_uid: String # The uid of the model, for saving and loading purpouses

var type: ItemEnums.ItemTypes ## Defines what item slot it uses, extends to other resources. Set in the child class
var type_max_owned_amount: int = 1 ## How many of this item type the player is allowed to have. NOTE: Only overwrite in _init. in resources directly extending BaseResource


# Abstract method
func get_modifier_string() -> Array[String]:
	printerr("get_modifier_string() should be overwritten in child class")
	return []


func get_modifier() -> Array[float]:
	printerr("get_modifier() should be overwritten in child class")
	return []
