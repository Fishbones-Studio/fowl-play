# NextEnemy box, for starting the next round
class_name NextEnemyBox
extends DialogueBox

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
