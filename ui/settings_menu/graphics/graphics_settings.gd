class_name GraphicsSettings
extends Resource

@export var default_settings: Dictionary =  {
	"resolution": Vector2i(1152, 648),
	"display_mode": DisplayServer.WINDOW_MODE_MAXIMIZED,
	"borderless": false,
	"v_sync": DisplayServer.VSYNC_ENABLED,
	"fps": 0,
	"msaa": Viewport.MSAA_DISABLED,
	"fxaa": Viewport.SCREEN_SPACE_AA_DISABLED,
	"taa": false,
	"render_scale": 0.5,
	"render_mode": Viewport.SCALING_3D_MODE_BILINEAR,
}
