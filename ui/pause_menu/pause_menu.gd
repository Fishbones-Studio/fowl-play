extends Control

@export var chicken: Node3D
@export var camera: Camera3D
@export var footer: PanelContainer
@export var game_logo_container: MarginContainer


func setup(params: Dictionary = {}) -> void:
	_init_footer()
	_init_chicken()
	_setup_enter_and_exit_transitions()


func _init_footer():
	footer.position.y += footer.size.y # Position footer below the screen
	
	TweenManager.create_move_tween(null, footer, "y", 592)


func _init_chicken():
	var chicken_tween: Tween = chicken.create_tween()
	
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.7, 1.5, 0.7), 0.3)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.1, 1.1, 1.1), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.9, 0.9, 0.9), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.0, 1.0, 1.0), 0.1)
	
	camera.position.y = 5.5
	TweenManager.create_move_tween(null, camera, "y", 1.5, 0.3)


func _setup_enter_and_exit_transitions():
	var buttons = find_children("", "Button", true)
	
	for button in buttons:
		button.mouse_entered.connect(func(): 
			TweenManager.create_scale_tween(null, button, Vector2(1.1, 1.1)))
		button.mouse_exited.connect(func():
			TweenManager.create_scale_tween(null, button, Vector2(1.0, 1.0)))
	
	game_logo_container.mouse_entered.connect(func():
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.1, 1.1)))
	game_logo_container.mouse_exited.connect(func(): 
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.0, 1.0)))
