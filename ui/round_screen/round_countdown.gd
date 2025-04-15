extends Control

@onready var countdown_label: Label = $MarginContainer/CountdownLabel


func update_countdown(display_text: String) -> void:
	countdown_label.text = display_text
