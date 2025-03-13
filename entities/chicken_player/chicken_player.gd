extends CharacterBody3D
class_name ChickenPlayer

# Player Stats export variables
@export_category("Stamina")
@export_range(10, 200) var max_stamina: float = 100
@export var stamina_regen: float = 5.0

@export_group("Health")
@export_range(10, 200) var max_health: int = 100

# Player stats
var stamina: float = max_stamina
var health: int    = max_health


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # TODO: move this somewhere ekse
	GameManager.chicken_player = self
	SignalManager.init_health.emit(max_health, health)


func _process(delta: float) -> void:
	# TODO: dont regen during sprint and dash
	stamina += stamina_regen * delta


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _exit_tree() -> void:
	GameManager.chicken_player = null
