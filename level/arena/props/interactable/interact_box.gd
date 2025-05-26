class_name InteractBox 
extends StaticBody3D

var player_in_area: bool = false

@onready var interact_control: Control = %InteractUi
@onready var name_label: Label3D = $NameLabel
@onready var interact_icon: Sprite2D = %Sprite2D

func _ready() -> void:
	SignalManager.keybind_changed.connect(_on_keybind_changed)
	_update_interact_icon()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area && !UIManager.game_input_blocked:
		interact()

func interact() -> void:
	push_error("Overwrite in child class")

func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	interact_control.visible = true
	_update_interact_icon()  # Update icon when player enters

func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	interact_control.visible = false
	player_in_area = false

func _on_keybind_changed(action_name: String) -> void:
	if action_name == "*" or action_name.to_lower() == "interact":
		_update_interact_icon()

func _update_interact_icon() -> void:
	if not is_instance_valid(interact_icon):
		return

	var icon_texture: Texture2D = IconManager.get_icon_texture("interact")
	interact_icon.texture = icon_texture
