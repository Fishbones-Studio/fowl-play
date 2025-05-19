# NextEnemy box, for starting the next round
class_name NextEnemyBox
extends InteractBox

@export var dialogue_subfolder_path : String = "in_between_rounds"

var dialogue_folder_path: String:
	set = _on_dialogue_folder_path_set

var dialogue_path: String


func _on_dialogue_folder_path_set(value: String) -> void:
	dialogue_folder_path = value
	dialogue_path = "" # Reset dialogue_path initially

	var in_between_rounds_path: String = dialogue_folder_path.path_join(
		dialogue_subfolder_path
	)

	# Check if the target directory exists within the resource system
	if not DirAccess.dir_exists_absolute(in_between_rounds_path):
		push_warning(
			"Dialogue subfolder does not exist or is not accessible: %s"
			% in_between_rounds_path
		)
		return # Exit if the directory isn't found

	var file_names_in_folder: PackedStringArray = ResourceLoader.list_directory(
		in_between_rounds_path
	)

	if file_names_in_folder.is_empty():
		push_warning(
			"No files found in dialogue subfolder by ResourceLoader: %s"
			% in_between_rounds_path
		)
		# dialogue_path remains "" as set initially
		return

	for file_name in file_names_in_folder:
		# We are looking for files, not directories.
		if not file_name.ends_with("/") and file_name.ends_with(
			".dialogue"
		) and not file_name.begins_with("."):
			dialogue_path = in_between_rounds_path.path_join(file_name)
			print("Selected dialogue file: %s" % dialogue_path) # For debugging
			break # Found the first matching dialogue file

	if dialogue_path.is_empty():
		push_warning(
			"No suitable '.dialogue' file found in: %s"
			% in_between_rounds_path
		)


func interact() -> void:
	if not dialogue_path.is_empty():
		# If a dialogue path is found, show the dialogue
		var resource: Resource = load(dialogue_path) # .dialogue files are typically Resources
		if resource && resource is DialogueResource:
			DialogueManager.show_dialogue_balloon(resource)
			await DialogueManager.dialogue_ended
			SignalManager.start_next_round.emit()
		else:
			push_error(
				"Failed to load dialogue resource from path: %s" % dialogue_path
			)
			# Fallback to starting next round immediately if loading fails
			SignalManager.start_next_round.emit()
	else:
		# If no dialogue path, or it's empty, start the next round immediately.
		push_warning(
			"No dialogue path set for NextEnemyBox, starting next round directly."
		)
		SignalManager.start_next_round.emit()
