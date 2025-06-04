extends UserInterface

@onready var play_button: Button = $MarginContainer/PlayButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var loading_label: Label = %LoadingLabel
@onready var loading_progress: ProgressBar = %LoadingProgress

var preload_manager: ShaderPreloadManager
var is_loading_complete: bool = false

func _ready() -> void:
	SettingsManager.load_settings(get_viewport(), get_window())

	if not music_player.playing:
		music_player.play()

	# Hide play button initially and show loading
	if play_button:
		play_button.visible = false
		play_button.disabled = true
	
	# Setup loading UI
	if loading_label:
		loading_label.text = "Loading shaders..."
		loading_label.visible = true
	
	if loading_progress:
		loading_progress.visible = true
		loading_progress.value = 0

	# Initialize shader preloading
	_setup_shader_preloading()

	super()

func _setup_shader_preloading() -> void:
	preload_manager = ShaderPreloadManager.new()
	add_child(preload_manager)
	
	# Connect signals
	preload_manager.preloader.preloading_started.connect(_on_preloading_started)
	preload_manager.preloader.preloading_progress.connect(_on_preloading_progress)
	preload_manager.preloader.preloading_completed.connect(_on_preloading_completed)
	preload_manager.preloader.preloading_failed.connect(_on_preloading_failed)
	
	# Start preloading TODO: Call defered
	preload_manager.preload_all_shaders()

func _on_preloading_started(total_scenes: int) -> void:
	print("Started preloading ", total_scenes, " scenes")
	if loading_label:
		loading_label.text = "Loading shaders... (0/" + str(total_scenes) + ")"

func _on_preloading_progress(current_scene: int, scene_path: String) -> void:
	var total_scenes: int = preload_manager.preloader._processed_materials.size() # Approximate
	
	if loading_label:
		loading_label.text = "Loading: " + scene_path.get_file()
	
	if loading_progress:
		# Calculate progress based on scenes processed
		var progress: float = (float(current_scene) / float(total_scenes)) * 100.0
		loading_progress.value = progress

func _on_preloading_completed() -> void:
	print("Shader preloading completed!")
	is_loading_complete = true
	
	# Hide loading UI
	if loading_label:
		loading_label.visible = false
	
	if loading_progress:
		loading_progress.visible = false
	
	# Show and enable play button
	if play_button:
		play_button.visible = true
		play_button.disabled = false
		play_button.grab_focus()

func _on_preloading_failed(error: String) -> void:
	print("Shader preloading failed: ", error)
	
	# Still show the play button even if preloading failed
	if loading_label:
		loading_label.text = "Loading failed, but game is playable"
		# Hide after a delay
		await get_tree().create_timer(2.0).timeout
		loading_label.visible = false
	
	if loading_progress:
		loading_progress.visible = false
	
	if play_button:
		play_button.visible = true
		play_button.disabled = false
		play_button.grab_focus()

func _gui_input(event: InputEvent) -> void:
	# Only allow input if loading is complete
	if not is_loading_complete:
		return
		
	if (event is InputEventMouseButton and event.pressed) or event is InputEventKey:
		_on_play_button_pressed()

func _on_play_button_pressed() -> void:
	# Don't allow play button to work if loading isn't complete
	if not is_loading_complete:
		return
		
	SaveManager.load_game_data()
	UIManager.remove_ui_by_enum(UIEnums.UI.SETTINGS_MENU)
	UIManager.remove_ui(self)
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU, UIEnums.UI.NULL)

func _on_settings_button_pressed() -> void:
	# Allow settings even during loading
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_reset_button_pressed() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.DELETE_SAVE_POPUP)
