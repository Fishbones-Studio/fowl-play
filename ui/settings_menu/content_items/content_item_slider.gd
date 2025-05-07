class_name SettingsSlider
extends Control

@onready var label: Label = %Label
@onready var slider_label: Label = %SliderLabel
@onready var slider: HSlider = %HSlider


func set_text(text: String) -> void:
	label.text = text


func set_value(value: float) -> void:
	slider.value = clampf(value, slider.min_value, slider.max_value)


func _on_h_slider_value_changed(value: float) -> void:
	slider_label.text = str(value)
