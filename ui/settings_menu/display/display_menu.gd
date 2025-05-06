################################################################################
### Script to display and manage display settings in a UI.
###
### This script handles the display settings UI, allowing users to set the  
### of busses and save their preferences.
################################################################################
extends Control

const RESOLUTIONS: Dictionary[String, Vector2i] = {
	"1152x648 - HD": Vector2i(1152, 648),
	"1280x720 - HD": Vector2i(1280, 720),
	"1366x768 - HD": Vector2i(1366, 768),
	"1600x900 - HD+": Vector2i(1600, 900),
	"1920x1080 - Full HD": Vector2i(1920, 1080),
	"2560x1440 - QHD": Vector2i(2560, 1440),
	"3840x2160 - 4K": Vector2i(3840, 2160),
}
const WINDOW_MODES: Dictionary[String, DisplayServer.WindowMode] = {
	"Windowed" : DisplayServer.WINDOW_MODE_WINDOWED,
	"Maximized" : DisplayServer.WINDOW_MODE_MAXIMIZED,
	"Fullscreen" : DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Exlusive Fullscreen" : DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
}
const V_SYNC: Dictionary = {
	"Disabled": DisplayServer.VSYNC_DISABLED,
	"Enabled": DisplayServer.VSYNC_ENABLED,
	"Adaptive": DisplayServer.VSYNC_ADAPTIVE,
}

var config_path: String = "user://settings.cfg"
var config_name: String = "display"
var display_settings: Dictionary

@onready var resolution: ContentItemDropdown = %Resolution
@onready var window_mode: ContentItemDropdown = %WindowMode
@onready var v_sync: ContentItemDropdown = %VSync


func _ready() -> void:
	resolution.options.clear()
	for res_text in RESOLUTIONS:
		resolution.options.add_item(res_text)

	window_mode.options.clear()
	for win_text in WINDOW_MODES:
		window_mode.options.add_item(win_text)

	v_sync.options.clear()
	for v_text in V_SYNC:
		v_sync.options.add_item(v_text)

	_load_display_settings()


func _load_display_settings() -> void:
	var config = ConfigFile.new()

	SaveManager.load_settings(config_name)

	_set_display_values()


func _save_display_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for display_setting: String in display_settings:
		config.set_value(config_name, display_setting, display_settings[display_setting])

	config.save(config_path)


func _set_resolution(index: int) -> void:
	var value: Vector2i = RESOLUTIONS.values()[index]
	DisplayServer.window_set_size(value)

	# Center window
	var centre_screen: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size: Vector2i = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size/2)

	resolution.options.selected = index
	display_settings["resolution"] = value

	_save_display_settings()


func _set_window_mode(index: int) -> void:
	var value: DisplayServer.WindowMode = WINDOW_MODES.values()[index]
	DisplayServer.window_set_mode(value)

	window_mode.options.selected = index
	display_settings["window_mode"] = value

	_save_display_settings()


func _set_vsync(index: int):
	var value: DisplayServer.VSyncMode = V_SYNC.values()[index]
	DisplayServer.window_set_vsync_mode(value)

	v_sync.options.selected = index
	display_settings["v_sync"] = value

	_save_display_settings()


func _set_display_values() -> void:
	_set_resolution(max(RESOLUTIONS.values().find(DisplayServer.window_get_size()), 0))
	_set_window_mode(WINDOW_MODES.values().find(DisplayServer.window_get_mode()))
	_set_vsync(V_SYNC.values().find(DisplayServer.window_get_vsync_mode()))
