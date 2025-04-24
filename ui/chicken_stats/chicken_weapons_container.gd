extends HBoxContainer

@onready var close_ranged_weapon_button: ChickenWeaponButton = $ChickenWeapon
@onready var long_ranged_weapon_button: ChickenWeaponButton = $ChickenWeapon2
@onready var weapon_description: RichTextLabel = $"../RichTextLabel"


func _ready() -> void:
	close_ranged_weapon_button.equiped_weapon = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.MELEE_WEAPON, 0
	)
	long_ranged_weapon_button.equiped_weapon = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.RANGED_WEAPON, 0
	)

	for button: ChickenWeaponButton in get_children():
		button.focus_entered.connect(_on_weapon_button_focus_entered.bind(button))
		if button.equiped_weapon:
			button.text = button.equiped_weapon.name
		else:
			button.text = "Not Equipped"

	_on_weapon_button_focus_entered(close_ranged_weapon_button)


func _on_weapon_button_focus_entered(weapon: ChickenWeaponButton) -> void:
	# Deactivate all buttons and update the description
	for button: ChickenWeaponButton in get_children():
		button.active = button == weapon

	if weapon.equiped_weapon:
		weapon_description.text = weapon.equiped_weapon.description
	else:
		weapon_description.text = "Not equipped."

	print("CRW Active: ", close_ranged_weapon_button.active, " | LRW Active: ", long_ranged_weapon_button.active)
