class_name ControlsSetting
extends Resource

## Use array for keeping the order
@export var default_settings: Array[Dictionary] = [
	{"horizontal_sensitivity": {"type": "slider", "min": 0.1, "max": 2.0, "step": 0.1, "value": 0.5}},
	{"vertical_sensivity": {"type": "slider", "min": 0.1, "max": 2.0, "step": 0.1, "value": 0.5}},
	{"controller_sensivity": {"type": "slider", "min": 0.1, "max": 8.0, "step": 0.1, "value": 8.0}},
	{"camera_up_tilt": {"type": "slider", "min": 0, "max": 90, "step": 1, "value": 45}},
	{"camera_down_tilt": {"type": "slider", "min": -90, "max": 0, "step": 1, "value": -90}},
	{"camera_spring_length": {"type": "slider", "min": 2.5, "max": 6.0, "step": 0.1, "value": 3.0}},
	{"camera_fov": {"type": "slider", "min": 75.0, "max": 120.0, "step": 0.1, "value": 75.0}},
	{"invert_x_axis": {"type": "check_button", "value": false}},
	{"invert_y_axis": {"type": "check_button", "value": false}},
]
