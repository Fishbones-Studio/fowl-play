extends Control

var is_transitioning: bool = false

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var victory_music_player : AudioStreamPlayer = $VictoryMusicPlayer



func _ready() -> void:
	get_tree().paused = true
	victory_music_player.play()
	animation_player.play("victory")


func _input(event: InputEvent) -> void:
	if (((event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT) or event.is_action_pressed("ui_accept"))
		and not animation_player.is_playing()
		and not is_transitioning
	):
		_return_to_game_menu()
		return

	get_viewport().set_input_as_handled()


func _return_to_game_menu() -> void:
	victory_music_player.stop()
	is_transitioning = true
	animation_player.play("RESET")

	get_tree().paused = false
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	
	UIManager.remove_ui(self)
