class_name InteractableBox 
extends StaticBody3D

var player_in_area: bool = false

@onready var interact_label: Control = %InteractUi
@onready var name_label: Label3D = $NameLabel
@onready var interact_icon: Sprite2D = %Sprite2D

func _ready() -> void:
	SignalManager.keybind_changed.connect(_update_interact_icon)
	_update_interact_icon()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		interact()

func interact() -> void:
	push_error("Overwrite in child class")

func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	interact_label.visible = true
	_update_interact_icon()  # Update icon when player enters

func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	interact_label.visible = false
	player_in_area = false

func _update_interact_icon() -> void:
	if not is_instance_valid(interact_icon):
		return
		
	var icon_path = "res://resources/controller-icons/interact.tres"
	var icon_resource = ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	
	if icon_resource and icon_resource is Texture2D:
		interact_icon.texture = icon_resource
	else:
		print("Failed to load interact icon")
		interact_icon.texture = null
