################################################################################
## Script to display and manage graphics settings in a UI.
##
## This script handles the graphics settings UI, allowing users to adjust and 
## save their graphics preferences. Handles resolution, window mode, borderless 
## toggle, VSync, and FPS limits.
################################################################################
extends Control

signal back_requested

const RESOLUTIONS: Dictionary[String, Vector2i] = {
	"1152x648 - HD": Vector2i(1152, 648),
	"1280x720 - HD": Vector2i(1280, 720),
	"1280x800 - HD SteamDeck" : Vector2i(1280, 800),
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
	"180": 180,
	"240": 240,
	"Unlimited": 0,
}
const MSAA: Dictionary[String, Viewport.MSAA] = {
	"Disabled - Fastest": Viewport.MSAA_DISABLED,
	"2x - Average": Viewport.MSAA_2X,
	"4x - Slow": Viewport.MSAA_4X,
	"8x - Slower": Viewport.MSAA_8X,
}
const FXAA: Dictionary[String, Viewport.ScreenSpaceAA] = {
	"Disabled - Fastest": Viewport.SCREEN_SPACE_AA_DISABLED,
	"Enabled - Fast": Viewport.SCREEN_SPACE_AA_FXAA,
}
const TAA: Dictionary[String, bool] = {
	"Disabled - Fastest": false,
	"Enabled - Average": true,
}
const RENDER_SCALE: Dictionary[String, float] = {
	"Default": 1.0,
	"Ultra Quality": 0.77,
	"Quality": 0.67,
	"Balanced": 0.59,
	"Performance": 0.5,
}
const RENDER_MODE: Dictionary[String, Viewport.Scaling3DMode] = {
	"Bilinear - Fastest": Viewport.SCALING_3D_MODE_BILINEAR,
	"FSR 1.0 - Fast": Viewport.SCALING_3D_MODE_FSR,
	"FSR 2.2 - Slow": Viewport.SCALING_3D_MODE_FSR2,
}

var config_path: String = "user://settings.cfg"
var config_name: String = "graphics"
var graphics_settings: Dictionary = {}

@onready var resolution: ContentItemDropdown = %Resolution
@onready var display_mode: ContentItemDropdown = %DisplayMode
@onready var borderless: ContentItemCheckButton = %Borderless
@onready var v_sync: ContentItemDropdown = %VSync
@onready var fps: ContentItemDropdown = %FPS
@onready var msaa: ContentItemDropdown = %MSAA
@onready var fxaa: ContentItemDropdown = %FXAA
@onready var taa: ContentItemDropdown = %TAA
@onready var render_scale: ContentItemDropdown = %RenderScale
@onready var render_mode: ContentItemDropdown = %RenderMode
@onready var post_processing_strength: ContentItemSlider = %PostProcessingStrength
@onready var preload_shaders_materials: ContentItemCheckButton = %PreloadShadersMaterials

@onready var restore_defaults_button: RestoreDefaultsButton = %RestoreDefaultsButton
@onready var content_container: VBoxContainer = %ContentContainer


func _ready() -> void:
	_load_graphics_items_only()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		UIManager.get_viewport().set_input_as_handled()


func _load_graphics_settings() -> void:
	SettingsManager.load_settings(get_viewport(),get_window(), config_name)
	_set_graphics_values()


func _save_graphics_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for graphics_setting: String in graphics_settings:
		config.set_value(config_name, graphics_setting, graphics_settings[graphics_setting])

	config.save(config_path)
	SignalManager.graphics_settings_changed.emit()


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

	_update_resolution_visibility()
	_save_graphics_settings()


func _set_borderless(value: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, value)
	DisplayServer.window_set_size(RESOLUTIONS.values()[resolution.options.selected])
	DisplayUtils.center_window(get_window())

	graphics_settings["borderless"] = value

	_save_graphics_settings()


## Vsync is enabled by default.
## Vertical synchronization locks framerate and makes screen tearing not visible
## at the cost of higher input latency and stuttering when the framerate target
## is not met.Adaptive V-Sync automatically disables V-Sync when the framerate 
## target is not met, and enables V-Sync otherwise. This prevents suttering and 
## reduces input latency when the framerate target is not met, at the cost of 
## visible tearing.
func _set_vsync(index: int) -> void:
	var value: DisplayServer.VSyncMode = V_SYNC.values()[index]
	DisplayServer.window_set_vsync_mode(value)

	v_sync.options.selected = index
	graphics_settings["v_sync"] = value

	_save_graphics_settings()


## The rendering FPS affects the appearance of TAA, as higher framerates allow 
## it to converge faster. On high refresh rate monitors, TAA ghosting issues 
## may appear less noticeable as a result (if the GPU can keep up).
func _set_fps(index: int) -> void:
	var value: int = FPS.values()[index]
	Engine.set_max_fps(value)

	fps.options.selected = index
	graphics_settings["fps"] = value

	_save_graphics_settings()


## Multi-sample anti-aliasing. High quality, but slow. It also does not smooth 
## out the edges of transparent (alpha scissor) textures.
func _set_msaa(index: int) -> void:
	var value: Viewport.MSAA = MSAA.values()[index]
	get_viewport().msaa_3d = value

	msaa.options.selected = index
	graphics_settings["msaa"] = value

	_save_graphics_settings()


## Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha 
## scissor edges), but blurs the whole scene rendering slightly.
func _set_fxaa(index: int) -> void:
	var value: Viewport.ScreenSpaceAA = FXAA.values()[index]
	get_viewport().screen_space_aa = value

	fxaa.options.selected = index
	graphics_settings["fxaa"] = value

	_save_graphics_settings()


## Temporal antialiasing. Smooths out everything including specular aliasing, 
## but can introduce ghosting artifacts and blurring in motion. 
## Moderate performance cost.
func _set_taa(index: int) -> void:
	var value: bool = TAA.values()[index]
	get_viewport().use_taa = value

	taa.options.selected = index
	graphics_settings["taa"] = value

	_save_graphics_settings()


## Render scale is a technique to render the scene at a lower resolution and upscale it to the display resolution.
func _set_render_scale(index: int) -> void:
	var value: float = RENDER_SCALE.values()[index]
	get_viewport().scaling_3d_scale = value

	render_scale.options.selected = index
	graphics_settings["render_scale"] = value

	_save_graphics_settings()


## Slider for the post processing effect
func _set_render_mode(index: int) -> void:
	var value: Viewport.Scaling3DMode = RENDER_MODE.values()[index]
	get_viewport().scaling_3d_mode = value

	render_mode.options.selected = index
	graphics_settings["render_mode"] = value

	_save_graphics_settings()


func _on_post_processing_strength_slider_value_changed(value) -> void:
	graphics_settings["pp_shader"] = value
	_save_graphics_settings()


func _set_preload_shaders(value: bool) -> void:
	graphics_settings["preload_shaders"] = value
	_save_graphics_settings()


# Separated loading items from setting up focus navigation
func _load_graphics_items_only() -> void:
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

	msaa.options.clear()
	for msaa_text in MSAA:
		msaa.options.add_item(msaa_text)

	fxaa.options.clear()
	for fxaa_text in FXAA:
		fxaa.options.add_item(fxaa_text)

	taa.options.clear()
	for taa_text in TAA:
		taa.options.add_item(taa_text)

	render_scale.options.clear()
	for scale_text in RENDER_SCALE:
		render_scale.options.add_item(scale_text)

	render_mode.options.clear()
	for mode_text in RENDER_MODE:
		render_mode.options.add_item(mode_text)

	_load_graphics_settings()


func _load_graphics_items() -> void:
	_load_graphics_items_only()
	_setup_focus_navigation()


func _set_graphics_values() -> void:
	resolution.options.select(max(RESOLUTIONS.values().find(DisplayServer.window_get_size()), 0))
	display_mode.options.select(DISPLAY_MODES.values().find(DisplayServer.window_get_mode()))
	borderless.set_pressed_no_signal(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
	v_sync.options.select(V_SYNC.values().find(DisplayServer.window_get_vsync_mode()))
	fps.options.select(FPS.values().find(Engine.max_fps))
	msaa.options.select(MSAA.values().find(get_viewport().msaa_3d))
	fxaa.options.select(FXAA.values().find(get_viewport().screen_space_aa))
	taa.options.select(TAA.values().find(get_viewport().use_taa))
	render_scale.options.select(RENDER_SCALE.values().find(max(snappedf(get_viewport().scaling_3d_scale, 0.01), 0.5)))
	render_mode.options.select(RENDER_MODE.values().find(get_viewport().scaling_3d_mode))
	post_processing_strength.set_value(SettingsManager.get_setting("graphics", "pp_shader", 2))
	preload_shaders_materials.set_pressed_no_signal(SettingsManager.get_setting("graphics", "preload_shaders", true))

	_update_resolution_visibility()


func _on_restore_defaults_button_up() -> void:
	SettingsManager.remove_setting_from_config(config_name)
	_load_graphics_items()


func _update_resolution_visibility() -> void:
	var selected_mode: DisplayServer.WindowMode = DISPLAY_MODES.values()[display_mode.options.selected]
	resolution.visible = selected_mode not in [
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	]


func _setup_focus_navigation() -> void:
	# Collect only visible Control nodes in the content container
	var nodes: Array = []

	for child in content_container.get_children():
		if child is Control and child.is_visible_in_tree():
			nodes.append(child)

	# Append the restore button only if it's visible
	if restore_defaults_button.is_visible_in_tree():
		nodes.append(restore_defaults_button)

	var count: int = nodes.size()
	if count == 0:
		return

	# Wire up top/bottom neighbors and next/previous in a circular list
	for i in range(count):
		var ctrl: Control = nodes[i]
		var prev: Control = nodes[(i - 1 + count) % count]
		var next: Control = nodes[(i + 1) % count]

		ctrl.focus_neighbor_top = prev.get_path()
		ctrl.focus_neighbor_bottom = next.get_path()
		ctrl.focus_next = next.get_path()
		ctrl.focus_previous = prev.get_path()
		ctrl.focus_mode = Control.FOCUS_ALL
