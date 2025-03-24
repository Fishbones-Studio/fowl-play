class_name InAranaShopItem
extends PanelContainer

var purchase_in_progress: bool = false
var upgrade_item: Resource

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")


@onready var name_label: Label = %NameLabel
@onready var bonus_label: Label = %BonusLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel


func set_item(item: InRunUpgradeResource) -> void: 
	name_label.text = item.name
	bonus_label.text = item.get_bonus_string() 
	cost_label.text = str(item.cost)
	description_label.text = item.description
	
	upgrade_item = item



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _buy_upgrade() -> void:
	pass

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
