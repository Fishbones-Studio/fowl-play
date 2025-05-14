class_name ContentItemSlider
extends Control

signal slider_value_changed(value: float)

@onready var label: Label = %Label
@onready var slider_label: Label = %SliderLabel
@onready var slider: HSlider = %HSlider
@onready var panel: Panel = %Panel


func set_text(text: String) -> void:
	label.text = text


func set_value(value: float) -> void:
	slider.value = clampf(value, slider.min_value, slider.max_value)


func _on_h_slider_value_changed(value: float) -> void:
	slider_label.text = str(value)
  slider_value_changed.emit(value)


func _on_focus_entered() -> void:
	slider.grab_focus()


func _on_h_slider_focus_entered() -> void:
	_set_neighbors_for(slider)
	_toggle_active(panel, true)


func _on_h_slider_focus_exited() -> void:
	_toggle_active(panel, false)
