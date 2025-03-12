extends Resource
class_name WeaponResource

# Common stats for all weapons (we gonna override these in their respective scripts)
@export var name: String = "Weapon"
@export var damage: int = 10
@export var attack_range: float = 1.5
@export var windup_time: float = 0.3
@export var attack_duration: float = 0.2
@export var cooldown_time: float = 0.5
@export var model: PackedScene  # 3D model for the weapon
@export var icon: Texture  # the Icon for the shop/inventory


func attack():
	print(name, " attack!")
