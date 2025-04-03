class_name ChickenPlayer
extends CharacterBody3D

@export var stats: LivingEntityStats

@onready var movement_state_machine: MovementStateMachine = $MovementStateMachine


func _ready():
	stats.init()
	GameManager.chicken_player = self
	SignalManager.init_health.emit(stats.max_health, stats.current_health)
	SignalManager.init_stamina.emit(stats.max_stamina, stats.current_stamina)


func _input(event: InputEvent) -> void:
	movement_state_machine.input(event)


func _process(delta: float) -> void:
	movement_state_machine.process(delta)


func _physics_process(delta: float) -> void:
	movement_state_machine.physics_process(delta)


func _exit_tree() -> void:
	GameManager.chicken_player = null
