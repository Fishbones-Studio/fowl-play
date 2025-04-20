extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title: Label = $TitleLabel

var is_transitioning: bool = false


func _ready() -> void:
	get_tree().paused = true
	GameManager.reset_game()
	animation_player.play("fade_to_black")


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not animation_player.is_playing()
		and not is_transitioning
	):
		_return_to_game_menu()
		return

	get_viewport().set_input_as_handled()


func _return_to_game_menu() -> void:
	is_transitioning = true
	animation_player.play("fade_to_white")

	get_tree().paused = false
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")


	await animation_player.animation_finished

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	SignalManager.switch_ui_scene.emit(UIEnums.UI.PAUSE_MENU)
