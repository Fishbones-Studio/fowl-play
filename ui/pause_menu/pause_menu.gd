class_name PauseScreen 
extends UserInterface

@export var chicken: Node3D
@export var camera: Camera3D
@export var game_logo_container: MarginContainer

@onready var resume_button: Button = %ResumeButton
@onready var overview_button: Button = %OverviewButton
@onready var quit_button: Button = %QuitButton
@onready var forfeit_button: Button = %ForfeitButton
@onready var poultry_menu_button : Button = %PoultryMenuButton


func setup(_params: Dictionary = {}) -> void:
	_squish_chicken()
	_setup_enter_and_exit_transitions()


func _on_resume_button_pressed() -> void:
	UIManager.handle_pause()


func _on_overview_button_pressed() -> void:
	if UIEnums.UI.CHICKEN_STATS in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.CHICKEN_STATS)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.CHICKEN_STATS) 


func _on_settings_button_pressed() -> void:
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU) 


func _on_quit_button_pressed() -> void:
	# TODO: some popup about save state being possibly behind
	_return_to_main_menu()


func _on_forfeit_button_pressed() -> void:
	GameManager.reset_game()
	_return_to_game_menu()


func _on_poultry_menu_button_pressed() -> void:
	_return_to_game_menu()


func _set_button_visibility() -> void: 
	if not ready:
		await ready

	quit_button.visible = (SceneLoader.current_scene == SceneEnums.Scenes.POULTRY_MAN_MENU)
	poultry_menu_button.visible = (SceneLoader.current_scene == SceneEnums.Scenes.TRAINING_AREA)
	forfeit_button.visible = (SceneLoader.current_scene == SceneEnums.Scenes.SEWER_LEVEL)
	overview_button.visible = (SceneLoader.current_scene in [SceneEnums.Scenes.SEWER_LEVEL, SceneEnums.Scenes.TRAINING_AREA])


func _get_scene_loader_children() -> Array:
	var tree: SceneTree = get_tree()

	if not tree or not tree.root:
		return []
	if not tree.root.has_node("SceneLoader"):
		return []

	var scene_loader: Node = tree.root.get_node("SceneLoader")
	var children: Array = scene_loader.get_children().map(func(child): return child.name)

	return children


func _return_to_game_menu() -> void:
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU , UIEnums.UI.NULL)
	UIManager.paused = false


func _return_to_main_menu() -> void:
	SignalManager.remove_all_game_scenes.emit()
	SignalManager.switch_ui_scene.emit(UIEnums.UI.MAIN_MENU)
	UIManager.remove_ui(self)
	UIManager.paused = false


func _on_visibility_changed() -> void:
	if visible: 
		UIManager.paused = true
		_squish_chicken()

	if is_inside_tree():
		resume_button.grab_focus()
		_set_button_visibility()


func _squish_chicken() -> void:
	var chicken_tween: Tween = chicken.create_tween()

	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.7, 1.5, 0.7), 0.2)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.1, 1.1, 1.1), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(0.9, 0.9, 0.9), 0.1)
	TweenManager.create_scale_tween(chicken_tween, chicken, Vector3(1.0, 1.0, 1.0), 0.1)

	camera.position.y = 5.5
	TweenManager.create_move_tween(null, camera, "y", 1.5, 0.3)


func _setup_enter_and_exit_transitions() -> void:
	var buttons: Array[Node] = find_children("", "Button", true)

	for button: Button in buttons:
		var hover_stylebox: StyleBox = preload("uid://do8svyygf5k1e")

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
			button.add_theme_stylebox_override('focus', hover_stylebox))

	game_logo_container.mouse_entered.connect(func():
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.1, 1.1)))
	game_logo_container.mouse_exited.connect(func(): 
		TweenManager.create_scale_tween(null, game_logo_container, Vector2(1.0, 1.0)))


func _on_focus_lost() -> void:
	_squish_chicken()
	super()
