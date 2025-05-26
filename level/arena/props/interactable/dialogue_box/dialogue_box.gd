class_name DialogueBox
extends InteractBox

@export var dialogue_subfolder_path: String
 # Optional: specify a file to load, will fall back to first
@export var dialogue_file_name: String = ""

var dialogue_folder_path: String:
	set = _on_dialogue_folder_path_set

var dialogue_path: String

func _on_dialogue_folder_path_set(value: String) -> void:
	dialogue_folder_path = value
	dialogue_path = ""

	var subfolder_path := dialogue_folder_path.path_join(dialogue_subfolder_path)

	if not DirAccess.dir_exists_absolute(subfolder_path):
		push_warning(
			"Dialogue subfolder does not exist or is not accessible: %s"
			% subfolder_path
		)
		return

	var file_names := ResourceLoader.list_directory(subfolder_path)
	if file_names.is_empty():
		push_warning(
			"No files found in dialogue subfolder: %s"
			% subfolder_path
		)
		return

	var found := false
	for file_name in file_names:
		print("Dialogue file: "+ file_name)
		if file_name.ends_with("/") or file_name.begins_with("."):
			continue
		if not file_name.ends_with(".dialogue"):
			continue
		if dialogue_file_name != "" and file_name != dialogue_file_name:
			continue
		dialogue_path = subfolder_path.path_join(file_name)
		print("Selected dialogue file: %s" % dialogue_path)
		found = true
		break

	if not found:
		push_warning(
			"No suitable '.dialogue' file found in: %s"
			% subfolder_path
		)

func interact() -> void:
	if dialogue_path.is_empty():
		push_warning("No dialogue file selected to interact with.")
		return
	var resource := load(dialogue_path)
	if resource and resource is DialogueResource:
		DialogueManager.show_dialogue_balloon(resource)
	else:
		push_warning("Failed to load or invalid DialogueResource: %s" % dialogue_path)
