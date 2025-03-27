extends VBoxContainer

@onready var health_bar: HealthBar = %HealthBar
@onready var stamina_bar: StaminaBar = %StaminaBar


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Initializing the health and stamina bars
	SignalManager.hurt_player.connect(func (damage): health_bar.health -= damage)
	SignalManager.init_health.connect(health_bar.init_health)
	
	SignalManager.init_stamina.connect(stamina_bar.init)
	SignalManager.stamina_changed.connect(stamina_bar.set_stamina)
