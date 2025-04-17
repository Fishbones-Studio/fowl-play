class_name DamageNumberHandler
extends Marker3D

@export_group("Popup settings")
@export var horizontal_spread = 2.2
@export var vertical_variance = 1.4
@export var depth_offset = 0.7

@export_group("Text settings")
@export var base_size: int = 140
@export var size_variation: int = 2
@export var damage_color: Color = Color.RED
@export var heal_color: Color = Color.GREEN

@onready var damage_number_resource: PackedScene = preload("uid://dhlso5fbo76px")


func display_damage(value: int) -> void:
	var damage_number: DamageNumber = damage_number_resource.instantiate()

	var spawn_position: Vector3 = global_position + Vector3(
		randf_range(-horizontal_spread, horizontal_spread),
		randf_range(0, vertical_variance),
		randf_range(-depth_offset, depth_offset)
	)
	
	add_child(damage_number)
	
	damage_number.global_position = spawn_position
	damage_number.label.text = str(value)
	damage_number.label.font_size = base_size * randi_range(1, size_variation)
	damage_number.label.modulate = damage_color if value >= 0 else heal_color

	var tween = damage_number.create_tween()
	TweenManager.create_move_tween(tween, damage_number, "y", damage_number.position.y + 1, 0.25, Tween.TRANS_CUBIC,Tween.EASE_OUT)
	TweenManager.create_move_tween(tween, damage_number, "y", damage_number.position.y, 0.5, Tween.TRANS_CUBIC,Tween.EASE_IN)
	tween.finished.connect(func(): damage_number.queue_free())
