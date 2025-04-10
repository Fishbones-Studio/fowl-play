extends Node3D

@export_group("Popup settings")
@export var horizontal_spread = 2.2
@export var vertical_variance = 1.4
@export var depth_offset = 0.7

@export_group("Text settings")
@export var base_size: int = 140
@export var size_variation: float = 0.2
@export var damage_color: Color = Color.RED

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_value_label: Label3D = $Anchor/Label3D


func display_damage(value: int) -> void:
	damage_value_label.text = str(value)
	damage_value_label.font_size = base_size * randf_range(1.0 - size_variation, 1.0 + size_variation)
	damage_value_label.modulate = damage_color

	animation_player.play("popup")


func remove() -> void:
	queue_free()
