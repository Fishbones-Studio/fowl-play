# NextEnemy box, for starting the next round
class_name NextEnemyBox extends InteractableBox

var dialogue_folder_path : String:
	set = _on_dialogue_folder_path_set


var dialogue_path : String


func _on_dialogue_folder_path_set(value: String) -> void:
		dialogue_folder_path = value
		var in_between_rounds_path: String = dialogue_folder_path.path_join("in_between_rounds")
		var dir: DirAccess                 = DirAccess.open(in_between_rounds_path)
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and not file_name.begins_with(".") and file_name.ends_with(".dialogue"):
					dialogue_path = in_between_rounds_path.path_join(file_name)
					break
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			push_warning("No Dialogue Found")
			dialogue_path = ""

func interact() -> void:
	if dialogue_path and not dialogue_folder_path.is_empty():
		# If a dialogue path is provided, show the dialogue
		var resource = load(dialogue_path)
		DialogueManager.show_dialogue_balloon(resource)
		await DialogueManager.dialogue_ended
		SignalManager.start_next_round.emit()
	else:
		# If no dialogue path, or it's empty, start the next round immediately.
		SignalManager.start_next_round.emit()
