class_name ControllerMappings

const ASSETS_PATH: String = "res://addons/controller_icons/assets/"

const CONTROLLER_NAMES_XBOX: Array[String] = ["xbox", "x-input"]
const CONTROLLER_NAMES_SONY: Array[String] = ["ps4", "ps3", "ps5", "dualsense", "sony", "dualshock"]
const CONTROLLER_NAMES_SWITCH: Array[String] = ["switch", "nintendo"]


const JOYPAD_MAPPINGS: Dictionary[String, Dictionary] = {
	"buttons": {
		0: {"xboxseries": "a", "ps5": "cross", "switch": "b"},
		1: {"xboxseries": "b", "ps5": "circle", "switch": "a"},
		2: {"xboxseries": "x", "ps5": "square", "switch": "y"},
		3: {"xboxseries": "y", "ps5": "triangle", "switch": "x"},
		4: {"xboxseries": "view", "ps5": "share", "switch": "minus"},
		5: {"xboxseries": "NA", "ps5": "NA", "switch": "NA"},
		6: {"xboxseries": "menu", "ps5": "options", "switch": "plus"},
		7: {"xboxseries": "l_stick_click", "ps5": "l_stick_click", "switch": "l_stick"}, # No click icon for switch
		8: {"xboxseries": "r_stick_click", "ps5": "r_stick_click", "switch": "r_stick"}, # No click icon for switch
		9: {"xboxseries": "lb", "ps5": "l1", "switch": "l"},
		10: {"xboxseries": "rb", "ps5": "r1", "switch": "r"},
		11: {"xboxseries": "dpad_up", "ps5": "dpad_up", "switch": "dpad_up"},
		12: {"xboxseries": "dpad_down", "ps5": "dpad_down", "switch": "dpad_down"},
		13: {"xboxseries": "dpad_left", "ps5": "dpad_left", "switch": "dpad_left"},
		14: {"xboxseries": "dpad_right", "ps5": "dpad_right", "switch": "dpad_right"},
		15: {"xboxseries": "share", "ps5": "microphone", "switch": "square"},
	},

	"axes": {
		0: {"xboxseries": "l_stick", "ps5": "l_stick", "switch": "l_stick"},
		1: {"xboxseries": "l_stick", "ps5": "l_stick", "switch": "l_stick"},
		2: {"xboxseries": "r_stick", "ps5": "r_stick", "switch": "r_stick"},
		3: {"xboxseries": "r_stick", "ps5": "r_stick", "switch": "r_stick"},
		4: {"xboxseries": "lt", "ps5": "l2", "switch": "zl"},
		5: {"xboxseries": "rt", "ps5": "r2", "switch": "zr"},
	}
}


static func get_controller_name(controller_name: String) -> String:
	for name in CONTROLLER_NAMES_XBOX:
		if name in controller_name:
			return "xboxseries"
	for name in CONTROLLER_NAMES_SONY:
		if name in controller_name:
			return "ps5"
	for name in CONTROLLER_NAMES_SWITCH:
		if name in controller_name:
			return "switch"

	return ""


static func get_asset(type: String, index: int) -> Array[String]:
	# Validate input type
	if type not in ["buttons", "axes"] or index not in JOYPAD_MAPPINGS[type]:
		push_warning("Incorrect controller action event.")
		return []

	var joypads: Array[int] = Input.get_connected_joypads()
	var joy_id: int = joypads[0] if not joypads.is_empty() else -1
	var controller_name: String = Input.get_joy_name(joy_id).to_lower()

	if joy_id == -1:
		push_warning("No joypads connected.")
		return []

	# Get the mapping for this input
	var mapping: Dictionary = JOYPAD_MAPPINGS[type][index]

	controller_name = get_controller_name(controller_name)

	# Build paths for all platforms
	var paths: Array[String] = []
	if controller_name in mapping:  # Check if platform exists in mapping
		var asset_name: String = mapping[controller_name]
		if asset_name != "NA":  # Skip unavailable mappings
			paths.append(ASSETS_PATH + controller_name + "/" + asset_name + ".png")

	return paths


static func extract_joypad_from_action(action: String) -> Dictionary:
	var result: Dictionary = {"type": "", "index": -1}

	if "Button" in action:
		result["type"] = "buttons"

	elif "Axis" in action:
		result["type"] = "axes"

	var regex: RegEx = RegEx.new()
	regex.compile("\\d+")
	var regex_result: RegExMatch = regex.search(action)
	if regex_result:
		result["index"] = regex_result.get_string().to_int()

	return result
