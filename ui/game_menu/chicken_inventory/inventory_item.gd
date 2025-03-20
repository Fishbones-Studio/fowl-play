extends PanelContainer

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")

@onready var item_icon: TextureRect = %ItemIcon
@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: Label = %DescriptionLabel


func _on_mouse_entered() -> void:
	if not theme:
		theme = Theme.new()  # Create a new Theme if it doesn't exist
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)


func _on_mouse_exited() -> void:
	if not theme:
		theme = Theme.new()  # Create a new Theme if it doesn't exist
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)
