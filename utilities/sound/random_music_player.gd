extends AudioStreamPlayer

@export var music_folder: String = "res://ui/game_menu/art/random_music/"
@export var min_interval: float = 30.0  ## Minimum time between songs in seconds
@export var max_interval: float = 60.0 ## Maximum time between songs in seconds

var available_songs: Array[AudioStream] = []
var current_song_index: int = -1
var timer: Timer


func _ready() -> void:
	# Load all audio files from the specified folder
	_load_music_files()
	
	if !available_songs.size() > 0:
		push_warning("No music files found in: %s" % music_folder)
		return
	
	# Set up timer
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_play_random_song)
	timer.start(randf_range(min_interval, max_interval))


func _load_music_files() -> void:
	var dir := DirAccess.open(music_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in ["ogg", "wav", "mp3"]:
				var song = load(music_folder.path_join(file_name))
				if song is AudioStream:
					available_songs.append(song)
			file_name = dir.get_next()
	else:
		push_error("Could not open music directory: %s" % music_folder)


func _play_random_song() -> void:
	if available_songs.size() == 0:
		return
	
	# If we have more than one song, make sure we don't play the same one twice in a row
	var next_index: int = current_song_index
	if available_songs.size() > 1:
		while next_index == current_song_index:
			next_index = randi() % available_songs.size()
	
	current_song_index = next_index
	stream = available_songs[current_song_index]
	
	# Print the current song name (without path or extension)
	var song_name: String = available_songs[current_song_index].resource_path.get_file().get_basename()
	print("Now playing: ", song_name)
	
	play()
	
	# Set up timer for next song
	var interval: float = randf_range(min_interval, max_interval)
	timer.start(interval + stream.get_length())  # Wait until current song ends + random interval
