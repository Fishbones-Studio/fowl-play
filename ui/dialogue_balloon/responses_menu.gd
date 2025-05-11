@icon("res://addons/dialogue_manager/assets/responses_menu.svg")

## A [Container] for dialogue responses provided by [b]Dialogue Manager[/b].
class_name ResponsesMenu extends Container


## Emitted when a response is selected.
signal response_selected(response)


## Optionally specify a control to duplicate for each response
@export var response_template: DialogueResponseContainer

## The action for accepting a response (is possibly overridden by parent dialogue balloon).
@export var next_action: StringName = &""

## Hide any responses where [code]is_allowed[/code] is false
@export var hide_failed_responses: bool = false

## The list of dialogue responses.
var responses: Array = []:
	get:
		return responses
	set(value):
		responses = value

		# Remove any current items
		for item in get_children():
			if item == response_template: continue

			remove_child(item)
			item.queue_free()

		# Add new items
		if responses.size() > 0:
			for response in responses:
				if hide_failed_responses and not response.is_allowed: continue

				var item: DialogueResponseContainer
				if is_instance_valid(response_template):
					item = response_template.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_USE_INSTANTIATION)
					item.show()
				item.name = "Response%d" % get_child_count()
				if not response.is_allowed:
					item.name = item.name + &"Disallowed"
					item.disabled = true

				item.set_meta("response", response)

				add_child(item)
				item.setup_response_button(response, response_selected)

			_configure_focus()

func _ready() -> void:
	visibility_changed.connect(func():
		if visible:
			var items = get_menu_items()
			if items.size() > 0:
				var first_item: Control = items[0]
				if first_item.is_inside_tree():
					first_item.grab_focus()
	)

	if is_instance_valid(response_template):
		response_template.hide()

## Get the selectable buttons in the menu.
func get_menu_items() -> Array:
	var items: Array = []
	for child in get_children():
		if not child.visible: continue
		if "Disallowed" in child.name: continue
		items.append(child) # The container itself
	return items


#region Internal

func _configure_focus() -> void:
	var items: Array = get_menu_items()
	if items.is_empty():
		return

	for i in items.size():
		var item: Control = items[i]
		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = items[items.size() - 1].get_path()
			item.focus_previous = items[items.size() - 1].get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = items[0].get_path()
			item.focus_next = items[0].get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		if item.mouse_entered.is_connected(_on_response_mouse_entered):
			item.mouse_entered.disconnect(_on_response_mouse_entered)
		if item.gui_input.is_connected(_on_response_gui_input):
			item.gui_input.disconnect(_on_response_gui_input)

		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item, item.get_meta("response")))

	items[0].grab_focus()


#endregion

#region Signals

func _on_response_mouse_entered(item: Control) -> void:
	item.grab_focus()

func _on_response_gui_input(event: InputEvent, item: Control, response) -> void:
	if "Disallowed" in item.name: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		response_selected.emit(response)
	elif event.is_action_pressed(&"ui_accept" if next_action.is_empty() else next_action):
		get_viewport().set_input_as_handled()
		response_selected.emit(response)
	elif event is InputEventKey and event.is_pressed():
		var items: Array = get_menu_items()
		var idx: int = items.find(item)
		if idx == -1:
			return
		if event.keycode == KEY_UP or event.keycode == KEY_W:
			items[(idx - 1) % items.size()].grab_focus()
		elif event.keycode == KEY_DOWN or event.keycode == KEY_S:
			items[(idx + 1) % items.size()].grab_focus()

#endregion
