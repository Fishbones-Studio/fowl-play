extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: RichTextLabel = $ColorRect/TitleLabel
@onready var timer: Timer = $Timer
@onready var label_timer: Timer = $Label_Timer

signal transitioned
var is_fading_black = false
	
	
func transition():
	animation_player.play("fade_to_black"	)
	is_fading_black = true
	Engine.time_scale = 0.75
	visible = true
	Gamemanager.reset_game()
	label_timer.start()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		emit_signal("transitioned")
		
		timer.start()

func _on_timer_timeout() -> void:
	if is_fading_black:
		Engine.time_scale = 1.0
		animation_player.play("fade_to_normal")
		SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
		SignalManager.switch_ui_scene.emit("uid://dnq3em8w064n4")

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_fading_black = false
	


func _on_label_timer_timeout() -> void:
	title_label.visible = true
