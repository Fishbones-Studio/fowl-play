class_name ControllerMappings

const ASSETS_PATH: String = "res://addons/controller_icons/assets/"


const JOYPAD_MAPPINGS: Dictionary[String, Dictionary] = {
	"buttons": {
		0: {"xboxseries": "a", "ps5": "cross", "switch": "b"},
		1: {"xboxseries": "b", "ps5": "circle", "switch": "a"},
		2: {"xboxseries": "x", "ps5": "square", "switch": "y"},
		3: {"xboxseries": "y", "ps5": "triangle", "switch": "x"},
		4: {"xboxseries": "lb", "ps5": "l1", "switch": "l"},
		5: {"xboxseries": "rb", "ps5": "r1", "switch": "r"},
		6: {"xboxseries": "view", "ps5": "share", "switch": "minus"},
		7: {"xboxseries": "menu", "ps5": "options", "switch": "plus"},
		8: {"xboxseries": "l_stick", "ps5": "l_stick", "switch": "l_stick"},
		9: {"xboxseries": "r_stick", "ps5": "r_stick", "switch": "r_stick"},
		10: {"xboxseries": "NA", "ps5": "NA", "switch": "home"},
		11: {"xboxseries": "dpad_up", "ps5": "dpad_up", "switch": "dpad_up"},
		12: {"xboxseries": "dpad_down", "ps5": "dpad_down", "switch": "dpad_down"},
		13: {"xboxseries": "dpad_left", "ps5": "dpad_left", "switch": "dpad_left"},
		14: {"xboxseries": "dpad_right", "ps5": "dpad_right", "switch": "dpad_right"}
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


static func get_asset(type: String, index: int) -> Array[String]:
	# Validate input type
	if type not in ["buttons", "axes"] or index not in JOYPAD_MAPPINGS[type]:
		return []

	# Get the mapping for this input
	var mapping: Dictionary = JOYPAD_MAPPINGS[type][index]

	# Build paths for all platforms
	var paths: Array[String] = []
	for platform in ["xboxseries", "ps5", "switch"]:
		if platform in mapping:  # Check if platform exists in mapping
			var asset_name: String = mapping[platform]
			if asset_name != "NA":  # Skip unavailable mappings
				paths.append(ASSETS_PATH + platform + "/" + asset_name + ".png")

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
