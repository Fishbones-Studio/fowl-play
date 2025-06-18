extends Control

# Array of random facts about chickens
const CHICKEN_FACTS: Array[String] = [
	"Chickens can recognize over 100 different faces, including humans!",
	"A chicken's heart beats about 300 times per minute.",
	"Chickens have better color vision than humans.",
	"Mother hens talk to their chicks while they're still in the egg.",
	"Chickens are the closest living relatives to the T-Rex.",
	"Chickens can remember and recognize over 100 different faces of people or animals.",
	"A chicken can run at 9 miles per hour when it wants to.",
	"Chickens have a special gland that helps them make vitamin D from sunlight.",
	"There are more chickens on Earth than any other bird species.",
	"Chickens dream when they sleep, just like humans do.",
	"What came first, the chicken or the egg?",
]

@export_dir var path_to_background_art: String = "res://ui/load_screen/art/"

var target_progress: float = 0.0
var current_progress: float = 0.0
var dot_count: int = 0

var background_textures: Array[CompressedTexture2D] = []
var next_ui: UIEnums.UI
var next_ui_params: Dictionary = {}

@onready var background_art: TextureRect = %BackgroundArt
@onready var fact_label: Label = %FactLabel
@onready var loading_text: Label = %LoadingLabel
@onready var progress_bar: ProgressBar = %LoadingProgressBar


func _ready() -> void:
	background_textures = _load_background_textures()
	SignalManager.loading_screen_started.connect(_on_loading_started)
	SignalManager.loading_progress_updated.connect(_on_progress_updated)
	SignalManager.loading_screen_finished.connect(_on_loading_finished)


func _process(delta) -> void:
	current_progress = move_toward(current_progress, target_progress, delta)
	progress_bar.value = clamp(current_progress * progress_bar.max_value * 2, 0, progress_bar.max_value)


func _update_loading_text() -> void:
	if not visible: 
		return

	dot_count = (dot_count + 1) % 4
	loading_text.text = "Now Loading" + ".".repeat(dot_count)

	get_tree().create_timer(0.3).timeout.connect(_update_loading_text, CONNECT_ONE_SHOT)


func _load_background_textures() -> Array[CompressedTexture2D]:
	var files: PackedStringArray = ResourceLoader.list_directory(path_to_background_art)

	if not files:
		push_error("An error occurred when trying to access path: ", path_to_background_art)
		return []

	var textures: Array[CompressedTexture2D] = []

	for file in files:
		if file.get_extension().to_lower() in ["png", "jpg"]:
			var file_path: String = path_to_background_art.path_join(file)
			var res: Resource = load(file_path)
			if res is CompressedTexture2D:
				textures.append(res)
			else:
				push_warning("File '", file, "' is not a CompressedTexture2D")

	return textures


func _on_loading_started(_next_ui : UIEnums.UI, _next_ui_params : Dictionary) -> void:
	next_ui = _next_ui
	next_ui_params = _next_ui_params

	current_progress = 0.0
	target_progress = 0.0
	progress_bar.value = 0

	visible = true
	fact_label.text = CHICKEN_FACTS.pick_random()
	background_art.texture = background_textures.pick_random()
	_update_loading_text()  


func _on_progress_updated(progress: float) -> void:
	target_progress = progress


func _on_loading_finished() -> void:
	progress_bar.value = 100
	loading_text.text = "Loading..."

	if next_ui and next_ui != UIEnums.UI.LOADING_SCREEN:
		SignalManager.switch_ui_scene.emit(next_ui, next_ui_params)
		next_ui = UIEnums.UI.LOADING_SCREEN
		next_ui_params = {}

	visible = false
