extends Control

@onready var h_slider: HSlider = %HSlider
@onready var slider_label: Label = %SliderLabel


func _process(delta: float) -> void:
	slider_label.text = str(h_slider.value)
