class_name SettingsSliderItem
extends Control

@onready var label: Label = %Label
@onready var slider_label: Label = %SliderLabel
@onready var slider: HSlider = %HSlider


func set_text(text: String) -> void:
	label.text = text


func set_value(value: float) -> void:
	slider.value = value
	slider_label.text = str(value)
