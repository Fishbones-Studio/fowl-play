extends Control

@onready var countdown_label: Label = $MarginContainer/CountdownLabel


func update_countdown(seconds: int) -> void:
	countdown_label.text = "Next round in: %d seconds" % seconds
