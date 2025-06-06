# NextEnemy box, for starting the next round
class_name NextEnemyBox
extends DialogueBox

func interact() -> void:
	_resolve_dialogue_path()
	if not dialogue_resource_path.is_empty():
		# If a dialogue path is found, show the dialogue
		var resource: Resource = load(dialogue_resource_path)
		if resource && resource is DialogueResource:
			if not DialogueManager.dialogue_ended.is_connected(_start_next_round):
				# Bind the specific dialogue resource that triggered this interaction, so other dialogues wont trigger the next round.
				DialogueManager.dialogue_ended.connect(
					_start_next_round.bind(resource)
				)
			DialogueManager.show_dialogue_balloon(resource)
			
		else:
			push_error(
				"Failed to load dialogue resource from path: %s" % dialogue_resource_path
			)
			# Fallback to starting next round immediately if loading fails
			SignalManager.start_next_round.emit()
	else:
		# If no dialogue path, or it's empty, start the next round immediately.
		push_warning(
			"No dialogue path set for NextEnemyBox, starting next round directly."
		)
		SignalManager.start_next_round.emit()

func _start_next_round(dialogue_resource: DialogueResource, resource_to_check : DialogueResource) -> void:
	if dialogue_resource == resource_to_check:
		SignalManager.start_next_round.emit()
