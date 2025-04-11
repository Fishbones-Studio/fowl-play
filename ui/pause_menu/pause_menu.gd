extends Control

@export var chicken: Node3D
@export var camera: Camera3D
@export var footer: PanelContainer
@export var game_logo_container: MarginContainer

var prev_mouse_mode: Input.MouseMode
var paused: bool:
	set(value):
		paused = value
		visible = value
		get_tree().paused = value
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else prev_mouse_mode
		if value: # TODO: Whack
			get_parent().move_child(self, get_parent().get_child_count() - 1) 
			_set_button_visibility()

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var forfeit_button: Button = %ForfeitButton


func _ready() -> void:
	SignalManager.settings_menu_toggled.connect(_toggle_settings_menu)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if not paused: 
			prev_mouse_mode = Input.mouse_mode

		paused = not paused

		if paused: 
			_squish_chicken()
			resume_button.grab_focus()


func setup(_params: Dictionary = {}) -> void:
	_init_footer()
	_squish_chicken()
	_setup_enter_and_exit_transitions()


func _init_footer() -> void:
	footer.position.y += footer.size.y # Position footer below the screen
	TweenManager.create_move_tween(null, footer, "y", 592)


func _squish_chicken() -> void:
	var chicken_tween: Tween = chicken.create_tween()

	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.7, 1.5, 0.7), 0.3)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.1, 1.1, 1.1), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.9, 0.9, 0.9), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.0, 1.0, 1.0), 0.1)

	camera.position.y = 5.5
	TweenManager.create_move_tween(null, camera, "y", 1.5, 0.3)


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


func _on_resume_button_button_up() -> void:
	paused = false


func _on_settings_button_button_up() -> void:
	SignalManager.add_ui_scene.emit("uid://81fy3yb0j33w")


func _on_quit_button_button_up() -> void:
	paused = false
	_return_to_main_menu()


func _on_forfeit_button_button_up() -> void:
	paused = false
	_return_to_game_menu()


func _set_button_visibility() -> void: 
	var children: Array = _get_scene_loader_children()

	quit_button.visible = "GameMenu" in children
	forfeit_button.visible = "Level" in children


func _get_scene_loader_children() -> Array:
	var scene_loader: Node = get_tree().root.get_node("SceneLoader")
	var children: Array = scene_loader.get_children()\
		.map(func(child): return child.name)

	return children


func _return_to_game_menu() -> void:
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	SignalManager.switch_ui_scene.emit("uid://dnq3em8w064n4")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _return_to_main_menu() -> void:
	SignalManager.switch_game_scene.emit("uid://dab0i61vj1n23")
	SignalManager.switch_ui_scene.emit("uid://dab0i61vj1n23")


func _toggle_settings_menu(value: bool) -> void:
	if value:
		set_process_input(false)
	else:
		set_process_input(true)
