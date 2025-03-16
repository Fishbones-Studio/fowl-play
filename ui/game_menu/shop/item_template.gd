extends Control
class_name Item_Template
@onready var item_name: Label = $VBoxContainer/item_name
@onready var item_cost: Label = $VBoxContainer/item_cost
@onready var item_type: Label = $VBoxContainer/item_type
@onready var ConfirmationPopup: Control = get_tree().get_root().find_child("ConfirmationPopup", true, false)

var purchase_in_progress = false

func set_item(item):
	item_name.text = item.name
	item_type.text = item.type
	item_cost.text = str(item.cost)

func _on_buy_item_pressed() -> void:
	
	if purchase_in_progress:
		return
		
	#Prevent the purchase from happening multiple times
	purchase_in_progress = true
	
	if Gamemanager.prosperity_eggs >= int(item_cost.text):
		var new_item = {
			"name": item_name.text,
			"type": item_type.text,
			"cost": int(item_cost.text)
		}
		
		var existing_item = Inventory.get_item_by_type(new_item.type)
		
		#Special case for ability type
		if new_item.type == "Ability":
			#check if ability already exists in inventory
			var existing_ability = Inventory.get_item_by_name(new_item.name)
			if existing_ability != null:
				print("Cannot buy the same ability twice!")
				purchase_in_progress = false
				return
				
			if existing_item == null:
				existing_item = []
			elif existing_item is Dictionary:
				existing_item = [existing_item]
				
			if existing_item.size() < 2:
				Inventory.add_item(new_item)
				Gamemanager.update_prosperity_eggs(-int(item_cost.text))	
				print("item bought")
				purchase_in_progress = false
				return
			else:
				#Disconnect any previous signal
				_disconnect_confirmation_signals()
				
				ConfirmationPopup.confirmed.connect(_on_confirmation_accepted)
				ConfirmationPopup.canceled.connect(_on_confirmation_canceled)
				
				ConfirmationPopup.show_confirmation(existing_item, new_item)
			
		#for non-ability types and type ability that has 2 in inventory		
		elif existing_item:
			if ConfirmationPopup:
				_disconnect_confirmation_signals()
				
				ConfirmationPopup.confirmed.connect(_on_confirmation_accepted)
				ConfirmationPopup.canceled.connect(_on_confirmation_canceled)
				
				ConfirmationPopup.show_confirmation(existing_item, new_item)
			
			else:
				print("Error: Confirmation popup not found!")
		
		else:
			Inventory.add_item(new_item)
			Gamemanager.update_prosperity_eggs(-int(item_cost.text))
			print("Item Bought!")
			purchase_in_progress = false
		
	else:
		print("Not enhough proseperity eggs.")
		purchase_in_progress = false
	
func _on_confirmation_accepted(old_item, new_item):
	Inventory.remove_item(old_item)
	Inventory.add_item(new_item)
	Gamemanager.update_prosperity_eggs(-new_item.cost)
	print("Replaced ", old_item.name, " with ", new_item.name)
	
	purchase_in_progress = false
	
	_disconnect_confirmation_signals()
	
func _on_confirmation_canceled():
	print("Item replacement canceled.")

	purchase_in_progress = false
	
	_disconnect_confirmation_signals()
	
func _disconnect_confirmation_signals():
	if ConfirmationPopup.confirmed.is_connected(_on_confirmation_accepted):
		ConfirmationPopup.confirmed.disconnect(_on_confirmation_accepted)
	if ConfirmationPopup.canceled.is_connected(_on_confirmation_canceled):
		ConfirmationPopup.canceled.disconnect(_on_confirmation_canceled)
