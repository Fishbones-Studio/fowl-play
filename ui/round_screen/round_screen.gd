extends Control

var display_text: String 

@onready var title: Label = $CenterContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer


func _ready() -> void:
	title.text = display_text
	animation_player.play("fade")
	animation_timer.start()


func _input(event: InputEvent) -> void:
	if visible: get_viewport().set_input_as_handled() # Block all input


func setup(params: Dictionary) -> void:
	display_text = params.get("display_text")


func _on_animation_timer_timeout() -> void:
	UIManager.remove_ui(self)
	# Since remove_ui will trigger mouse_mode_visible, explicitly set captured here
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
