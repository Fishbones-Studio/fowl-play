class_name IntermissionArea extends Node3D

@export var round_handler : RoundHandler

var enemy_model : Node3D

@onready var next_enemy_box : InteractableBox = $NextEnemy

func _ready():
	if round_handler && next_enemy_box:
		round_handler.next_enemy_selected.connect(_on_next_enemy_selected)
		
func _physics_process(_delta: float) -> void:
	if enemy_model && GameManager.chicken_player:
		enemy_model.look_at(GameManager.chicken_player.global_position)
		# rotate the enemy model 180 degrees, currently looks at the player with the backside
		enemy_model.rotate_y(deg_to_rad(90))
		
		
		
func _on_next_enemy_selected(next_enemy : Enemy) -> void:
	if(next_enemy.enemy_model):
		enemy_model = next_enemy.enemy_model.duplicate()
		next_enemy_box.add_child(enemy_model)
		# check if the enemy model has an animation player, and if so play Idle
		var animation_player : AnimationPlayer = enemy_model.get_node("AnimationPlayer")
		if animation_player:
			# TODO: animation naming should really be the same for each enemy
			if animation_player.has_animation("Idle"):
				animation_player.play("Idle")
			elif animation_player.has_animation("idle"):
				animation_player.play("idle")
		else:
			push_warning("No animationplayer found")
	else:
		push_warning("next_enemy has no enemy model set")
