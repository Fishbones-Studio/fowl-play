class_name ControlOverview extends Control

@export var control_text_dict : Dictionary[StringName, String]:
	set(value):
		control_text_dict = value
		_update_control_visuals()

@onready var control_container : GridContainer = %ControlContainer

var _icon_nodes: Dictionary = {}

func _ready() -> void:
	if control_text_dict && !control_text_dict.is_empty() && control_container:
		_update_control_visuals()
	SignalManager.keybind_changed.connect(_on_keybind_changed)

func _on_keybind_changed(keybind : String) -> void:
	var keybind_name: StringName = StringName(keybind)
	if _icon_nodes.has(keybind_name):
		var texture_rect: TextureRect = _icon_nodes[keybind_name]
		var controller_texture_icon: ControllerIconTexture = ControllerIconTexture.new()
		controller_texture_icon.path = keybind_name
		texture_rect.texture = controller_texture_icon

func _update_control_visuals() -> void:
	if !control_container:
		return

	for child in control_container.get_children():
		child.queue_free()
	_icon_nodes.clear()

	for keybind_name: StringName in control_text_dict.keys():
		var texture_rect: TextureRect = TextureRect.new()
		var controller_texture_icon: ControllerIconTexture = ControllerIconTexture.new()
		controller_texture_icon.path = keybind_name
		texture_rect.texture = controller_texture_icon
		texture_rect.custom_minimum_size = Vector2(48, 48)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		control_container.add_child(texture_rect)
		_icon_nodes[keybind_name] = texture_rect

		var label: Label = Label.new()
		label.text = control_text_dict[keybind_name]
		label.theme_type_variation = "HeaderSmall"
		control_container.add_child(label)

func setup(params: Dictionary) -> void:
	if params.has("control_text_dict"):
		var input_dict: Dictionary = params["control_text_dict"]
		var typed_dict: Dictionary[StringName, String] = {}
		for key in input_dict.keys():
			var string_name_key: StringName = StringName(key)
			var string_value: String = String(input_dict[key])
			typed_dict[string_name_key] = string_value
		control_text_dict = typed_dict
