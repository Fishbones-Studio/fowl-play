class_name IntermissionArea 
extends Node3D

@export var round_handler: RoundHandler

var enemy_model: Node3D
var player_in_area: bool = false
var initial_enemy_rotation: Basis

@onready var next_enemy_box: NextEnemyBox = $NextEnemy
@onready var player_detector: Area3D = $PlayerDetector


func _ready() -> void:
	if round_handler and next_enemy_box:
		round_handler.next_enemy_selected.connect(_on_next_enemy_selected)
	player_detector.body_entered.connect(_on_body_entered)
	player_detector.body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if player_in_area and enemy_model and GameManager.chicken_player:
		var target: Vector3 = GameManager.chicken_player.global_position
		target.y = enemy_model.global_transform.origin.y
		enemy_model.look_at(target)
		enemy_model.basis = enemy_model.basis * initial_enemy_rotation


func _on_next_enemy_selected(next_enemy: Enemy) -> void:
	if next_enemy and next_enemy.model and next_enemy.model.get_child_count():
		enemy_model = next_enemy.model.get_child(0).duplicate()
		next_enemy_box.add_child(enemy_model)
		next_enemy_box.dialogue_directory = next_enemy.dialogue_path.path_join("in_between_rounds")
		initial_enemy_rotation = enemy_model.basis.orthonormalized()
		var animation_player: AnimationPlayer = enemy_model.get_node_or_null("AnimationPlayer")
		if animation_player:
			if animation_player.has_animation("Idle"):
				animation_player.play("Idle")
			elif animation_player.has_animation("idle"):
				animation_player.play("idle")
		else:
			push_warning("No animationplayer found")
	else:
		push_warning("next_enemy has no enemy model set")


func _on_body_entered(body: Node) -> void:
	if body == GameManager.chicken_player and enemy_model:
		enemy_model.visible = true
		player_in_area = true


func _on_body_exited(body: Node) -> void:
	if body == GameManager.chicken_player and enemy_model:
		player_in_area = false
		enemy_model.visible = false
		if next_enemy_box:
			next_enemy_box.dialogue_directory = ""
