class_name BaseShopItem
extends PanelContainer

# Common properties
var purchase_in_progress: bool = false
var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")

# Common UI elements (should be overridden by child classes)
@onready var name_label: Label
@onready var cost_label: Label
@onready var description_label: Label
@onready var item_icon : TextureRect

## Abstract method, overwrite in child class
func set_item_data(item: Resource) -> void:
	push_error("set_item_data() must be implemented by child class")
	return

## Abstract method, overwrite in child class
func attempt_purchase() -> void:
	push_error("attempt_purchase() must be implemented by child class")
	return
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attempt_purchase()

func make_unclickable() -> void:
	disconnect("gui_input", _on_gui_input)

func _on_mouse_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)

func _on_mouse_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)

func can_afford() -> bool:
	return GameManager.prosperity_eggs >= int(cost_label.text)
