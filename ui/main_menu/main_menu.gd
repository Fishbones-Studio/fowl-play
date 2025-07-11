extends UserInterface

var preload_manager: ShaderPreloadManager
var is_loading_complete: bool = false

var _total_scenes_to_preload: int = 0

@onready var play_button: Button = %PlayButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var loading_label: Label = %LoadingLabel
@onready var loading_progress: ProgressBar = %LoadingProgress
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	version_label.text = "Version: %s" % ProjectSettings.get_setting("application/config/version")

	SettingsManager.load_settings(get_viewport(), get_window())

	if not music_player.playing:
		music_player.play()

	if SettingsManager.get_setting("graphics", "preload_shaders", true) and not is_loading_complete:

		# Hide play button initially
		if play_button:
			play_button.visible = false

		# Setup loading UI
		if loading_label:
			loading_label.text = "Loading shaders..."
			loading_label.visible = true

		if loading_progress:
			loading_progress.visible = true
			loading_progress.value = 0

		# Defer the setup and start of shader preloading to ensure the menu UI is visible first.
		call_deferred("_setup_shader_preloading")
	else:
		is_loading_complete = true
		# If shader preloading is disabled, show the play button immediately
		if play_button:
			play_button.visible = true
			play_button.grab_focus()
		if loading_label:
			loading_label.visible = false
		if loading_progress:
			loading_progress.visible = false
	super()


func _setup_shader_preloading() -> void:
	preload_manager = ShaderPreloadManager.new()
	add_child(preload_manager)

	# Connect signals
	if preload_manager.preloader:
		preload_manager.preloader.preloading_started.connect(_on_preloading_started)
		preload_manager.preloader.preloading_progress.connect(_on_preloading_progress)
		preload_manager.preloader.preloading_completed.connect(_on_preloading_completed)
		preload_manager.preloader.preloading_failed.connect(_on_preloading_failed)
	else:
		printerr("MainMenu: Preloader not ready in ShaderPreloadManager during _setup_shader_preloading.")

	# Start preloading
	preload_manager.preload_all_shaders()


func _on_preloading_started(total_scenes: int) -> void:
	_total_scenes_to_preload = total_scenes
	print("Started preloading ", total_scenes, " scenes")
	if loading_label:
		loading_label.text = "Loading shaders... (0/" + str(total_scenes) + ")"


func _on_preloading_progress(current_scene_index: int, scene_path: String) -> void:
	if loading_label && OS.has_feature("debug"):
		loading_label.text = "Loading: " + scene_path.get_file() + " (" + str(current_scene_index) + "/" + str(_total_scenes_to_preload) + ")"

	if loading_progress and _total_scenes_to_preload > 0:
		var progress: float = (float(current_scene_index) / float(_total_scenes_to_preload)) * 100.0
		loading_progress.value = progress
	elif loading_progress:
		loading_progress.value = 0


func _on_preloading_completed() -> void:
	print("Shader preloading completed!")
	is_loading_complete = true

	if loading_label:
		loading_label.visible = false

	if loading_progress:
		loading_progress.visible = false
		loading_progress.value = 100

	if play_button:
		play_button.visible = true
		play_button.grab_focus()


func _on_preloading_failed(error_message: String) -> void:
	preload_manager.queue_free()
	print("Shader preloading failed: ", error_message)
	is_loading_complete = true # Allow game to proceed

	if loading_label:
		loading_label.text = "Loading shaders failed. Game might have visual issues."
		loading_label.visible = false

	if loading_progress:
		loading_progress.visible = false

	if play_button:
		play_button.visible = true
		play_button.grab_focus()


func _gui_input(event: InputEvent) -> void:
	if not is_loading_complete:
		return

	# Input handling after loading is complete
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
		(event is InputEventKey and event.pressed and not event.is_echo()):
		if play_button.visible and not play_button.disabled:
			_on_play_button_pressed()


func _on_play_button_pressed() -> void:
	if not is_loading_complete:
		print("Cannot play: Loading not complete.")
		return

	SaveManager.load_game_data()
	UIManager.remove_ui_by_enum(UIEnums.UI.SETTINGS_MENU)
	UIManager.remove_ui(self)
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU, UIEnums.UI.NULL)


func _on_settings_button_pressed() -> void:
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU)


func _on_quit_button_pressed() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.QUIT_GAME_POPUP)


func _on_reset_button_pressed() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.DELETE_SAVE_POPUP)


func setup(params: Dictionary) -> void:
	is_loading_complete = params.get("skip_preload", false)
