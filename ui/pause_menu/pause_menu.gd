extends Control

@export var chicken: Node3D
@export var camera: Camera3D
@export var footer: PanelContainer
@export var game_logo_container: MarginContainer

@onready var resume_button: Button = %ResumeButton


func _ready() -> void:
	resume_button.grab_focus()


func setup(params: Dictionary = {}) -> void:
	_init_footer()
	_init_chicken()
	_setup_enter_and_exit_transitions()


func _init_footer() -> void:
	footer.position.y += footer.size.y # Position footer below the screen
	
	TweenManager.create_move_tween(null, footer, "y", 592)


func _init_chicken() -> void:
	_squish_chicken()
	
	camera.position.y = 5.5
	TweenManager.create_move_tween(null, camera, "y", 1.5, 0.3)


func _squish_chicken() -> void:
	var chicken_tween: Tween = chicken.create_tween()
	
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.7, 1.5, 0.7), 0.3)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.1, 1.1, 1.1), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.9, 0.9, 0.9), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.0, 1.0, 1.0), 0.1)


func _setup_enter_and_exit_transitions() -> void:
	var buttons: Array[Node] = find_children("", "Button", true)
	
	for button: Button in buttons:
		var hover_sylebox: StyleBox = preload("uid://do8svyygf5k1e")
		
		button.focus_entered.connect(func():
			TweenManager.create_scale_tween(null, button, Vector2(1.1, 1.1)))
		button.focus_exited.connect(func():
			TweenManager.create_scale_tween(null, button, Vector2(1.0, 1.0)))
		
		button.mouse_entered.connect(func():
			button.grab_focus()
			TweenManager.create_scale_tween(null, button, Vector2(1.1, 1.1)))
		button.mouse_exited.connect(func():
			if not button.has_focus():
				TweenManager.create_scale_tween(null, button, Vector2(1.0, 1.0)))
		
		button.button_down.connect(func():
			button.add_theme_stylebox_override('focus', StyleBoxEmpty.new()))
		button.button_up.connect(func():
			button.add_theme_stylebox_override('focus', hover_sylebox))
	
	game_logo_container.mouse_entered.connect(func():
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.1, 1.1)))
	game_logo_container.mouse_exited.connect(func(): 
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.0, 1.0)))
