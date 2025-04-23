extends GridContainer

@onready var prosperity_label: Label = %ProsperityEggsAmount
@onready var feathers_of_rebirth: Label = %FeathersOfRebirthAmount


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	GameManager.feathers_of_rebirth_changed.connect(_on_feathers_of_rebirth_changed)
	GameManager.prosperity_eggs_changed.connect(_on_prosperity_eggs_changed)

	# Get the current prosperity eggs and feathers of rebirth from game manager
	prosperity_label.text = str(GameManager.prosperity_eggs)
	feathers_of_rebirth.text = str(GameManager.feathers_of_rebirth)


func _on_feathers_of_rebirth_changed(new_value: int) -> void:
	feathers_of_rebirth.text = str(new_value)
	print("Feathers of Rebirth changed to: ", new_value)


func _on_prosperity_eggs_changed(new_value: int) -> void:
	prosperity_label.text = str(new_value)
	print("Prosperity Eggs changed to: ", new_value)
