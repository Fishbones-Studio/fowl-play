################################################################################
## Handles settings data persistance:
## - Settings (Controls, Key Bindings, Graphics, Audio)
#################################################################################
class_name SettingsManager 
extends Node

const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_CFG_NAME_CONTROLS: String = "controls"
const SETTINGS_CFG_NAME_KEYBINDS: String = "keybinds"
const SETTINGS_CFG_NAME_GRAPHICS: String = "graphics"
const SETTINGS_CFG_NAME_AUDIO: String = "audio"
const DEFAULT_GRAPHICS_SETTINGS: GraphicsSettings = preload("uid://bj6f5mcuyrlnf")

# Input remapping
# Signal would not work here, since signal order is not guaranteed, which can
# cause multiple input buttons to be pressed at the same time or other bugs
static var is_remapping: bool = false
static var input_type: SaveEnums.InputType
static var action_to_remap: String = ""


## Load all saved settings from the user's configuration file.
static func load_settings(viewport: Viewport, window: Window, item: String = "") -> void:
	var config: ConfigFile = ConfigFile.new()
	ensure_default_settings_saved()

	# Attempt to load config file - if failed, use defaults for requested section
	if config.load(SETTINGS_CONFIG_PATH) != OK:
		# Load default graphics settings if file doesn't exist or fails to load
		if item == SETTINGS_CFG_NAME_GRAPHICS or item.is_empty():
			if DEFAULT_GRAPHICS_SETTINGS:
				_apply_graphics_settings(DEFAULT_GRAPHICS_SETTINGS.default_settings.duplicate(true), viewport, window)
			else:
				push_error("Default graphics settings resource not loaded.")
		return

	if item == SETTINGS_CFG_NAME_KEYBINDS or item.is_empty():
		# Load keybind settings
		if config.has_section(SETTINGS_CFG_NAME_KEYBINDS):
			for action in config.get_section_keys(SETTINGS_CFG_NAME_KEYBINDS):
				InputMap.action_erase_events(action)
				var events = config.get_value(SETTINGS_CFG_NAME_KEYBINDS, action)
				if events is Array: # Ensure it's an array before iterating
					for event in events:
						if event is InputEvent: # Ensure it's an InputEvent
							InputMap.action_add_event(action, event)
						else:
							push_warning("Invalid event type for action '%s' in settings." % action)
				else:
					push_warning("Events for action '%s' not an array in settings." % action)

	if item == SETTINGS_CFG_NAME_GRAPHICS or item.is_empty():
		# Load graphics settings
		var graphics_settings: Dictionary
		if DEFAULT_GRAPHICS_SETTINGS:
			graphics_settings = DEFAULT_GRAPHICS_SETTINGS.default_settings.duplicate(true)
		else:
			push_error("Default graphics settings resource not loaded. Cannot load graphics settings.")
			return

		if config.has_section(SETTINGS_CFG_NAME_GRAPHICS):
			for graphics_setting_key in config.get_section_keys(SETTINGS_CFG_NAME_GRAPHICS):
				graphics_settings[graphics_setting_key] = config.get_value(SETTINGS_CFG_NAME_GRAPHICS, graphics_setting_key)
		_apply_graphics_settings(graphics_settings, viewport, window)

	if item == SETTINGS_CFG_NAME_AUDIO or item.is_empty():
		# Load audio settings
		if config.has_section(SETTINGS_CFG_NAME_AUDIO):
			for audio_bus_name in config.get_section_keys(SETTINGS_CFG_NAME_AUDIO):
				var saved_volume: float = config.get_value(SETTINGS_CFG_NAME_AUDIO, audio_bus_name)
				var bus_idx: int = AudioServer.get_bus_index(audio_bus_name)
				if bus_idx != -1: # Check if bus exists
					var volume_db: float = linear_to_db(clampf(saved_volume / 100, 0.0, 1.0)) # Assuming saved_volume is 0-100
					AudioServer.set_bus_volume_db(bus_idx, volume_db)
				else:
					push_warning("Audio bus '%s' not found." % audio_bus_name)


static func ensure_default_settings_saved() -> void:
	var config: ConfigFile= ConfigFile.new()
	var err: Error = config.load(SETTINGS_CONFIG_PATH)
	var is_empty: bool = err != OK or config.get_sections().is_empty()
	if not is_empty:
		return

	# Graphics defaults
	if DEFAULT_GRAPHICS_SETTINGS:
		for key in DEFAULT_GRAPHICS_SETTINGS.default_settings.keys():
			config.set_value(
				SETTINGS_CFG_NAME_GRAPHICS,
				key,
				DEFAULT_GRAPHICS_SETTINGS.default_settings[key]
			)
	else:
		push_error("Default graphics settings resource not loaded.")

	# Audio defaults
	config.set_value(SETTINGS_CFG_NAME_AUDIO, "Master", 100.0)
	config.set_value(SETTINGS_CFG_NAME_AUDIO, "Music", 100.0)
	config.set_value(SETTINGS_CFG_NAME_AUDIO, "SFX",   100.0)

	config.save(SETTINGS_CONFIG_PATH)


static func _apply_graphics_settings(settings: Dictionary, viewport: Viewport, window: Window) -> void:
	var res_changed: bool = false

	if DisplayServer.window_get_mode() != settings["display_mode"]:
		DisplayServer.window_set_mode(settings["display_mode"])
		res_changed = true

	if settings["display_mode"] not in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]: 
		if DisplayServer.window_get_size() != settings["resolution"]:
			DisplayServer.window_set_size(settings["resolution"])
			res_changed = true

	if DisplayServer.window_get_mode() not in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) != settings["borderless"]:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, settings["borderless"])
			res_changed = true

	if DisplayServer.window_get_vsync_mode() != settings["v_sync"]:
		DisplayServer.window_set_vsync_mode(settings["v_sync"])

	Engine.max_fps = settings["fps"]
	viewport.msaa_3d = settings["msaa"]
	viewport.screen_space_aa = settings["fxaa"]
	viewport.use_taa = settings["taa"]
	viewport.scaling_3d_scale = settings["render_scale"]
	viewport.scaling_3d_mode = settings["render_mode"]

	if res_changed:
		DisplayUtils.center_window(window)


## Method to get a specific setting from the config file
static func get_setting(section: String, key: String, default : Variant) -> Variant:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_CONFIG_PATH) == OK and config.has_section(section):
		return config.get_value(section, key, default)
	else:
		push_warning("Failed to load setting '%s' from section '%s'." % [key, section])
		return default


static func remove_setting_from_config(section_name: String) -> bool:
	var config: ConfigFile = ConfigFile.new()

	# Load the config file
	if config.load(SETTINGS_CONFIG_PATH) != OK:
		push_error("Error: Could not load config file!")
		return false

	# Check if the section exists before removing
	if config.has_section(section_name):
		config.erase_section(section_name)
		config.save(SETTINGS_CONFIG_PATH)
		print_rich("[color=orange]Removed section: %s[/color]" % section_name)
		return true
	else:
		printerr("Section does not exist: ", section_name)
		return false
