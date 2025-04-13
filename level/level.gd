class_name Level
extends Node3D

@export var total_rounds: int = 3
@export var enemies: Array[PackedScene]

var current_enemy: Enemy = null

@onready var enemy_position: Marker3D = $EnemyPosition

# TODO, randomize enemy, fix crack round screen
# fix enemy and player freeze during round
# utilize gamemanager more to store stuff

func _ready() -> void:
	GameManager.current_round = 0
	SignalManager.enemy_died.connect(_on_enemy_died)
	start_round()


func start_round() -> void:
	if GameManager.current_round >= total_rounds:
		print("win")
		SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
		SignalManager.switch_ui_scene.emit("uid://dnq3em8w064n4")
		return

	var enemy_scene = enemies[GameManager.current_round]
	var enemy = enemy_scene.instantiate()

	add_child(enemy)
	enemy.global_position = enemy_position.global_position
	current_enemy = enemy

	GameManager.current_round += 1
	SignalManager.add_ui_scene.emit("uid://61l26wjx0fux")
	print("Spawned ", current_enemy.name, " for Round ", GameManager.current_round)


# crack, realistically the enemy should enter the death state and there should be round states too to implement the intermissions for shop and others, wip
func _on_enemy_died() -> void:
	current_enemy = null
	start_round()
