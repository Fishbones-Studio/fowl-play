## Custom wrapper for the DialogueManager to handle balloon display via UIManager.
extends DialogueManagerBase

func _ready() -> void:
	super._ready()
	dialogue_ended.connect(_on_wrapper_dialogue_ended)


func _prepare_balloon_params(
	resource: DialogueResource, title: String, extra_game_states: Array
) -> Dictionary:
	return {
		"resource": resource,
		"title": title,
		"extra_game_states": extra_game_states,
	}


func _show_balloon_via_manager(
	resource: DialogueResource, title: String, extra_game_states: Array
) -> Node:
	if not is_instance_valid(UIManager):
		push_error(
			"DialogueManagerWrapper: UIManager not available. "
			+ "Falling back to default balloon handling."
		)
		return super.show_dialogue_balloon(resource, title, extra_game_states)

	var existing_balloon = UIManager.ui_list.get(UIEnums.UI.DIALOGUE_BALLOON)
	if is_instance_valid(existing_balloon):
		UIManager.toggle_ui(UIEnums.UI.DIALOGUE_BALLOON)
		await get_tree().process_frame

	SignalManager.add_ui_scene.emit(UIEnums.UI.DIALOGUE_BALLOON, {})
	await get_tree().process_frame

	var balloon_node = UIManager.ui_list.get(UIEnums.UI.DIALOGUE_BALLOON)

	if not is_instance_valid(balloon_node):
		push_error(
			"DialogueManagerWrapper: Dialogue balloon node not found in UIManager "
			+ "after attempting to add."
		)
		return null

	_start_balloon.call_deferred(balloon_node, resource, title, extra_game_states)

	return balloon_node


# Call "start" on the given balloon.
func _start_balloon(balloon: Node, resource: DialogueResource, title: String, extra_game_states: Array) -> void:
	if balloon.has_method(&"start"):
		balloon.start(resource, title, extra_game_states)
	elif balloon.has_method(&"Start"):
		balloon.Start(resource, title, extra_game_states)
	else:
		assert(false, DMConstants.translate(&"runtime.dialogue_balloon_missing_start_method"))

	dialogue_started.emit(resource)
	bridge_dialogue_started.emit(resource)


func _on_wrapper_dialogue_ended(_resource: DialogueResource) -> void:
	var balloon_in_list = UIManager.ui_list.get(UIEnums.UI.DIALOGUE_BALLOON)
	if is_instance_valid(balloon_in_list):
		UIManager.toggle_ui(UIEnums.UI.DIALOGUE_BALLOON)


# Overridden public methods from DialogueManager 
func show_example_dialogue_balloon(
	resource: DialogueResource, title: String = "", extra_game_states: Array = []
) -> CanvasLayer:
	return await _show_balloon_via_manager(resource, title, extra_game_states) as CanvasLayer


func show_dialogue_balloon(
	resource: DialogueResource, title: String = "", extra_game_states: Array = []
) -> Node:
	return await _show_balloon_via_manager(resource, title, extra_game_states)


func show_dialogue_balloon_scene(
	_balloon_scene_input,
	resource: DialogueResource,
	title: String = "",
	extra_game_states: Array = []
) -> Node:
	push_warning(
		"DialogueManagerWrapper: `_balloon_scene_input` in "
		+ "show_dialogue_balloon_scene is ignored. Using UIManager's default "
		+ "dialogue balloon (UIEnums.UI.DIALOGUE_BALLOON)."
	)
	return await _show_balloon_via_manager(resource, title, extra_game_states)
