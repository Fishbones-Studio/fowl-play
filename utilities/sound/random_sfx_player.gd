extends AudioStreamPlayer3D

@export var sounds_folder: String = "res://ui/game_menu/art/random_sounds/"
@export var min_interval: float = 5.0    # Minimum time between sounds in seconds
@export var max_interval: float = 15.0   # Maximum time between sounds in seconds
@export var max_random_distance: float = 10.0   # Maximum distance from origin for sound position
@export var min_random_distance: float = 2.0    # Minimum distance from origin for sound position

var available_sounds: Array[AudioStream] = []
var current_sound_index: int = -1
var timer: Timer


func _ready() -> void:
	# Load all audio files from the specified folder
	_load_sound_files()
	
	# Set up timer
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_play_random_sound)
	
	# Start playing sounds if we have any loaded
	if available_sounds.size() > 0:
		_play_random_sound()
	else:
		push_warning("No sound files found in: %s" % sounds_folder)


func _load_sound_files() -> void:
	var dir := DirAccess.open(sounds_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in ["ogg", "wav", "mp3"]:
				var sound = load(sounds_folder.path_join(file_name))
				if sound is AudioStream:
					available_sounds.append(sound)
			file_name = dir.get_next()
	else:
		push_error("Could not open sounds directory: %s" % sounds_folder)


func _play_random_sound() -> void:
	if available_sounds.size() == 0:
		return
	
	# If we have more than one sound, make sure we don't play the same one twice in a row
	var next_index: int = current_sound_index
	if available_sounds.size() > 1:
		while next_index == current_sound_index:
			next_index = randi() % available_sounds.size()
	
	current_sound_index = next_index
	stream = available_sounds[current_sound_index]
	
	# Set random position in 3D space
	var random_angle: float    = randf_range(0, 2 * PI)
	var random_distance: float = randf_range(min_random_distance, max_random_distance)
	position = Vector3(
		cos(random_angle) * random_distance,
		cos(random_angle) * random_distance,
		sin(random_angle) * random_distance
	)
	
	# Print the current sound name
	var sound_name: String = available_sounds[current_sound_index].resource_path.get_file().get_basename()
	print("Playing sound: ", sound_name, " from position: ", position)
	
	play()
	
	# Set up timer for next sound
	var interval: float = randf_range(min_interval, max_interval)
	timer.start(interval)
