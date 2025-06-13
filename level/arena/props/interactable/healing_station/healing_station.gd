extends InteractBox

signal heal_purchased

@export_range(0, 100, 1) var health: int = 25 ## In percentage
@export var cost: int = 10
@export var currency_type: CurrencyEnums.CurrencyTypes = CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS


func _ready() -> void:
	heal_purchased.connect(_on_heal_purchased)
	super()


func interact() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.HEALING_CONFIRMATION, {
		"heal_purchased_signal": heal_purchased,
		"health": health,
		"cost": cost
	})


func _on_heal_purchased() -> void:
	if GameManager.chicken_player.stats.current_health >= GameManager.chicken_player.stats.max_health:
		return
	if currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
		if GameManager.prosperity_eggs < cost:
			return
		GameManager.prosperity_eggs -= cost
	elif currency_type == CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
		if GameManager.feathers_of_rebirth < cost:
			return
		GameManager.feathers_of_rebirth -= cost
	GameManager.chicken_player.stats.restore_health(GameManager.chicken_player.stats.max_health * health / 100.0)
