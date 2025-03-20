extends CharacterBody3D
class_name ChickenPlayer

# Player Stats export variables
@export_category("Stamina")
@export_range(10, 200) var max_stamina: float = 100
@export var stamina_regen: float = 8.5

@export_group("Health")
@export_range(10, 200) var max_health: int = 100

# Player stats
var stamina: float = max_stamina:
	set(value): stamina = clamp(value, 0, max_stamina)

var health: int    = max_health


func _ready():
	GameManager.chicken_player = self

	SignalManager.init_health.emit(max_health, health)
	SignalManager.init_stamina.emit(max_stamina, stamina)
	SignalManager.hurt_player.connect(_on_player_take_damage)
	


func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	die()


func _exit_tree() -> void:
	GameManager.chicken_player = null


func regen_stamina(delta: float) -> void:
	stamina += stamina_regen * delta
	
func _on_player_take_damage(amount: int) -> void:
	health -= amount
	print("Player took %d damage! Remaining health: %d" % [amount, health])
	
	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE)
		
func die():
	if health <= 0:
		queue_free()
