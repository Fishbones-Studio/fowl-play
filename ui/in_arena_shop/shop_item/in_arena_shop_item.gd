class_name InArenaShopItem
extends PanelContainer

var purchase_in_progress: bool = false
var upgrade_item: Resource

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")

@onready var name_label: Label = %NameLabel
@onready var bonus_label: Label = %BonusLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel

func disable_item() -> void:
	self.visible = false


func set_item(item: InRunUpgradeResource) -> void: 
	name_label.text = item.name
	bonus_label.text = item.get_bonus_string()  
	cost_label.text = str(item.cost)
	description_label.text = item.description
	
	upgrade_item = item


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_buy_upgrade()	
			
			
func make_unclickable() -> void:
	disconnect("gui_input", _on_gui_input)


func _on_mouse_entered() -> void:
	if not theme:
		theme = Theme.new()  # Create a new Theme if it doesn't exist
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)


func _on_mouse_exited() -> void:
	if not theme:
		theme = Theme.new()  # Create a new Theme if it doesn't exist
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)


func _buy_upgrade() -> void:
	if purchase_in_progress:
		return  
	
	if GameManager.prosperity_eggs < int(cost_label.text):
		print("Not enough Prosperity Eggs. Current Prosperity Eggs: ", GameManager.prosperity_eggs)
		purchase_in_progress = false
		return
	
	# when buying a upgrade and the bonus property is above 0 we set the new values to that property
	if upgrade_item.health_bonus > 0:
		GameManager.chicken_player.stats.max_health += upgrade_item.health_bonus
		GameManager.chicken_player.stats.health += upgrade_item.health_bonus  

	if upgrade_item.stamina_bonus > 0:
		GameManager.chicken_player.stats.max_stamina += upgrade_item.stamina_bonus
		GameManager.chicken_player.stats.stamina += upgrade_item.stamina_bonus 
	
	# i am gonna add the other buffs later, for now i can only access these properties
	
	GameManager.prosperity_eggs -= int(cost_label.text)
	
	disable_item()
	
	purchase_in_progress = false
	
