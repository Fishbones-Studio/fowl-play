class_name DialogueBox
extends InteractBox

## The dialogue to play.
## If set, this specific file will be used and take priority over the dialogue_directory.
@export_file("*.dialogue")
var dialogue_file: String:
	set(value):
		dialogue_file = value
		if value and not value.is_empty():
			_resolve_dialogue_path()

## A directory containing dialogue files.
## If dialogue_file is not set, the script will automatically find the first '.dialogue' file in this directory.
@export_dir
var dialogue_directory: String :
	set(value):
		dialogue_directory = value
		if value and not value.is_empty():
			_resolve_dialogue_path()

# Variable to store the final path to the dialogue resource.
var dialogue_resource_path: String


func _ready() -> void:
	_resolve_dialogue_path()


# Sets the internal dialogue path based on the exported variables.
func _resolve_dialogue_path() -> void:
	# A specific file has been assigned.
	if not dialogue_file.is_empty():
		dialogue_resource_path = dialogue_file
		print("Using specified dialogue file: %s" % dialogue_resource_path)
		return

	# A directory has been assigned, but no specific file. Find the first '.dialogue' file in it.
	if not dialogue_directory.is_empty():
		if not DirAccess.dir_exists_absolute(dialogue_directory):
			push_warning(
				"Dialogue directory does not exist: %s" % dialogue_directory
			)
			return

		# Use DirAccess.get_files_at() to get a list of files.
		var files := DirAccess.get_files_at(dialogue_directory)
		for file_name in files:
			# Only care about files ending with the dialogue extension.
			if file_name.ends_with(".dialogue"):
				dialogue_resource_path = dialogue_directory.path_join(file_name)
				print(
					"Found and selected dialogue file: %s"
					% dialogue_resource_path
				)
				return

		# If the loop finishes, no suitable file was found.
		push_warning(
			"No '.dialogue' file found in directory: %s" % dialogue_directory
		)
		return

	# If we reach here, neither a file nor a directory was specified.
	push_warning(
		"No dialogue file or directory has been set for this DialogueBox."
	)

func interact() -> void:
	if dialogue_resource_path.is_empty():
		push_warning("Cannot interact: No dialogue resource path is configured.")
		return

	var resource : Resource = load(dialogue_resource_path)
	if resource is DialogueResource:
		if not DialogueManager.dialogue_ended.is_connected(dialogue_end):
				# Bind the specific dialogue resource that triggered this interaction, to properly check if the dialogue has ended
				DialogueManager.dialogue_ended.connect(
					dialogue_end.bind(resource)
				)
		DialogueManager.show_dialogue_balloon(resource)
	else:
		push_warning(
			"Failed to load or invalid DialogueResource at path: %s"
			% dialogue_resource_path
		)
		
## Method that runs after dialogue has ended
func dialogue_end(dialogue_resource: DialogueResource, resource_to_check : DialogueResource) -> void:
	if dialogue_resource == resource_to_check:
		print("Dialogue sucesfully ended")
