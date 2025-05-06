################################################################################
## Script to display and manage graphics settings in a UI.
##
## This script handles the graphics settings UI, allowing users to adjust and 
## save their graphics preferences. Handles resolution, window mode, borderless 
## toggle, VSync, and FPS limits.
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
const DISPLAY_MODES: Dictionary[String, DisplayServer.WindowMode] = {
	"Windowed" : DisplayServer.WINDOW_MODE_WINDOWED,
	"Maximized" : DisplayServer.WINDOW_MODE_MAXIMIZED,
	"Fullscreen" : DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Exlusive Fullscreen" : DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
}
const V_SYNC: Dictionary[String, DisplayServer.VSyncMode] = {
	"Disabled": DisplayServer.VSYNC_DISABLED,
	"Enabled": DisplayServer.VSYNC_ENABLED,
	"Adaptive": DisplayServer.VSYNC_ADAPTIVE,
}
const FPS: Dictionary[String, int] = {
	"30": 30,
	"60": 60,
	"120": 120,
	"Unlimited": 0,
}

var config_path: String = "user://settings.cfg"
var config_name: String = "graphics"
var graphics_settings: Dictionary = {}

@onready var resolution: ContentItemDropdown = %Resolution
@onready var display_mode: ContentItemDropdown = %DisplayMode
@onready var borderless: SettingsCheckButton = %Borderless
@onready var v_sync: ContentItemDropdown = %VSync
@onready var fps: ContentItemDropdown = %FPS


func _ready() -> void:
	resolution.options.clear()
	for res_text in RESOLUTIONS:
		resolution.options.add_item(res_text)

	display_mode.options.clear()
	for dis_text in DISPLAY_MODES:
		display_mode.options.add_item(dis_text)

	v_sync.options.clear()
	for v_text in V_SYNC:
		v_sync.options.add_item(v_text)

	fps.options.clear()
	for fps_text in FPS:
		fps.options.add_item(fps_text)

	_load_graphics_settings()


func _load_graphics_settings() -> void:
	var config = ConfigFile.new()

	SaveManager.load_settings(config_name)

	_set_graphics_values()


func _save_graphics_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for graphics_setting: String in graphics_settings:
		config.set_value(config_name, graphics_setting, graphics_settings[graphics_setting])

	config.save(config_path)


func _set_resolution(index: int) -> void:
	var value: Vector2i = RESOLUTIONS.values()[index]
	DisplayServer.window_set_size(value)
	DisplayUtils.center_window(get_window())

	resolution.options.selected = index
	graphics_settings["resolution"] = value

	_save_graphics_settings()


func _set_display_mode(index: int) -> void:
	var value: DisplayServer.WindowMode = DISPLAY_MODES.values()[index]
	DisplayServer.window_set_mode(value)

	display_mode.options.selected = index
	graphics_settings["display_mode"] = value

	_save_graphics_settings()


func _set_borderless(value: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, value)
	DisplayServer.window_set_size(graphics_settings["resolution"])
	DisplayUtils.center_window(get_window())

	graphics_settings["borderless"] = value

	_save_graphics_settings()
	print(DisplayServer.window_get_size())


func _set_vsync(index: int):
	var value: DisplayServer.VSyncMode = V_SYNC.values()[index]
	DisplayServer.window_set_vsync_mode(value)

	v_sync.options.selected = index
	graphics_settings["v_sync"] = value

	_save_graphics_settings()


func _set_fps(index: int):
	var value: int = FPS.values()[index]
	Engine.set_max_fps(value)

	fps.options.selected = index
	graphics_settings["fps"] = value

	_save_graphics_settings()


func _set_graphics_values() -> void:
	_set_resolution(max(RESOLUTIONS.values().find(DisplayServer.window_get_size()), 0))
	_set_display_mode(DISPLAY_MODES.values().find(DisplayServer.window_get_mode()))
	borderless.set_pressed_no_signal(DisplayServer.WINDOW_FLAG_BORDERLESS)
	_set_vsync(V_SYNC.values().find(DisplayServer.window_get_vsync_mode()))
	_set_fps(FPS.values().find(Engine.max_fps))
