extends Resource
class_name WeaponResource

# Common stats for all weapons (we gonna override these in their respective scripts)
@export var name: String 
@export var damage: int
@export var windup_time: float 
@export var attack_duration: float 
@export var cooldown_time: float 
@export var model: PackedScene
@export var icon: Texture  # the Icon for the shop/inventory


	
