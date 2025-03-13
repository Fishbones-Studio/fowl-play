extends Control
class_name Item_Template
@onready var item_name: Label = $VBoxContainer/item_name
@onready var item_cost: Label = $VBoxContainer/item_cost
@onready var item_type: Label = $VBoxContainer/item_type
@onready var ConfirmationPopup: Control = get_tree().get_root().find_child("ConfirmationPopup", true, false)

func set_item(item : Dictionary):
	item_name.text = item.name
	item_type.text = item.type
	item_cost.text = str(item.cost)
	
	


func _on_buy_item_pressed() -> void:
	if Gamemanager.prosperity_eggs >= int(item_cost.text):
		var new_item = {
			"name": item_name.text,
			"type": item_type.text,
			"cost": int(item_cost.text)
		}
		
		var existing_item = Inventory.get_item_by_type(new_item.type)
		
		if existing_item:
			if ConfirmationPopup:
				#Show the pupupscreen
				ConfirmationPopup.show_confirmation(existing_item, new_item)
				#Check if there is already a connection with signal to make sure that a connection is not made twice
				if ConfirmationPopup.confirmed.is_connected(_on_confirmation_accepted):
					ConfirmationPopup.confirmed.disconnect(_on_confirmation_accepted)
				if ConfirmationPopup.canceled.is_connected(_on_confirmation_canceled):
					ConfirmationPopup.canceled.disconnect(_on_confirmation_canceled)
				
				ConfirmationPopup.confirmed.connect(_on_confirmation_accepted)
				ConfirmationPopup.canceled.connect(_on_confirmation_canceled)
			else:
				print("Error: Confirmation popup not found!")
		else:
			#runs if the item type does not excist in inventory
			Inventory.add_item(new_item)
			Gamemanager.update_prosperityEggs(-int(item_cost.text))
			print("Item Bought!")
		
	else:
		print("Not enhough proseperity eggs.")
	
#Runs when user presses the 'Replace' button
func _on_confirmation_accepted(new_item : Dictionary):
	Inventory.remove_item_by_type(new_item.type)
	Inventory.add_item(new_item)
	Gamemanager.update_prosperityEggs(-new_item.cost)
	print("Replaced item with:", new_item)
#Runs when user presses the 'Cancel' button
func _on_confirmation_canceled():
	print("Item replacement canceled.")
