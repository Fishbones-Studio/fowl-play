extends Control

const CHICKEN_FACTS = [
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
	"What came first, the chicken or the egg?"
]

var target_progress: float = 0.0
var current_progress: float = 0.0
var dot_count: int = 0

@onready var progress_bar: ProgressBar = $HBoxContainer/VBoxContainer/ProgressBar
@onready var loading_text: Label = $HBoxContainer/VBoxContainer/Label
@onready var random_text: Label = $HBoxContainer2/VBoxContainer/Label


func _ready():
	SignalManager.loading_screen_started.connect(_on_loading_started)
	SignalManager.loading_progress_updated.connect(_on_progress_updated)
	SignalManager.loading_screen_finished.connect(_on_loading_finished)
	visible = false


func _on_loading_started():
	current_progress = 0.0
	target_progress = 0.0
	progress_bar.value = 0
	visible = true
	random_text.text = _get_random_chicken_fact()
	_update_loading_text()  
	set_process(true) 


func _get_random_chicken_fact() -> String:
	return CHICKEN_FACTS.pick_random()


func _on_progress_updated(progress: float):
	target_progress = progress  


func _process(delta):
	current_progress = move_toward(current_progress, target_progress, delta * 2.0)
	progress_bar.value = current_progress * 200.0
	
	
	if current_progress >= 1.0:
		set_process(false)
		_on_loading_finished()


func _update_loading_text():
	if not visible: return
	
	dot_count = (dot_count + 1) % 4
	loading_text.text = "Loading" + ".".repeat(dot_count)
	get_tree().create_timer(0.3).timeout.connect(_update_loading_text, CONNECT_ONE_SHOT)


func _on_loading_finished():
	progress_bar.value = 100
	loading_text.text = "Loading..."
	
	
	await get_tree().create_timer(0.15).timeout
	visible = false
