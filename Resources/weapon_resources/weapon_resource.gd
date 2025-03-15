## WeaponResource: Defines weapon properties that can be used across different weapons.
extends Resource
class_name WeaponResource

## Weapon Attributes
@export var name: String 
@export var damage: int

## Timing Variables
@export var windup_time: float 
@export var attack_duration: float 
@export var cooldown_time: float 

## Visual & UI Elements
@export var model: PackedScene
@export var icon: Texture  # The icon for the shop/inventory
