class_name InteractableBox extends StaticBody3D

var player_in_area: bool = false

@onready var interact_label = $Area3D/InteractLabel
@onready var name_label = $NameLabel


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		interact()
		
func interact() -> void:
	push_error("Overwrite in child class")


func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	interact_label.visible = true


func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	interact_label.visible = false
	player_in_area = false
