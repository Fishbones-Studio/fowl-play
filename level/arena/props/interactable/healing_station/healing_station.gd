extends InteractBox

@export var health := 10
@export var cost := 10
@export var currency_type : CurrencyEnums.CurrencyTypes = CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS
@export var interact_label_placeholder_text : String = "Press          to heal %d (costs %d %s)"

@onready var interact_label : Label = %InteractLabel

func _ready() -> void:
	super()
	interact_label.text = interact_label_placeholder_text % [health, cost, CurrencyEnums.currency_type_to_string(currency_type, true)]

func interact() -> void:
	GameManager.chicken_player.stats.restore_health(health)
	if currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
		GameManager.prosperity_eggs -= cost
	elif currency_type == CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
		GameManager.feathers_of_rebirth -= cost
