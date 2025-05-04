class_name UiItemSlot
extends CenterContainer

@export var item: BaseResource:
	set(value):
		item = value
		_update_item_visuals()

@export_group("Color")
@export var active_indicator_colour: Color
@export var item_background_colour: Color
@export var cooldown_colour: Color

var active: bool = false:
	set(value):
		active = value
		active_indicator.visible = value

var cooldown_tween: Tween
var cooldown_original_size: Vector2

@onready var active_indicator: ColorRect = $ActiveIndicator
@onready var item_image: TextureRect = $ItemImage
@onready var item_background: ColorRect = $ItemBackground
@onready var cooldown: ProgressBar = $Cooldown


func _ready() -> void:
	# Apply colors
	active_indicator.color = active_indicator_colour if active_indicator_colour else active_indicator.color
	item_background.color = item_background_colour if item_background_colour else item_background.color

	# Create a new StyleBoxFlat for the fill
	var fill_stylebox := StyleBoxFlat.new()
	fill_stylebox.bg_color = cooldown_colour if cooldown_colour else Color(1, 1, 1) # fallback colour
	
	# Apply the stylebox override to the ProgressBar's fill
	cooldown.add_theme_stylebox_override("fill", fill_stylebox)

	# Start hidden
	cooldown.visible = false
	active_indicator.visible = false

	_update_item_visuals()


func _update_item_visuals() -> void:
	if item_image and item:
		item_image.texture = item.icon


## Starting the visualization of the slot cooldown state
func start_cooldown(duration: float, create_tween := true) -> void:
	cooldown.visible = true

	# Set max_value to the cooldown duration
	cooldown.max_value = duration
	cooldown.value = duration

	if create_tween:
		# Stop and discard any existing tween
		if cooldown_tween and cooldown_tween.is_valid():
			cooldown_tween.kill()
		cooldown_tween = null

		# Animate value from duration to 0
		cooldown_tween = create_tween()
		cooldown_tween.tween_property(
			cooldown, "value", 0.0, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# Connect the finished signal if the tween was created successfully
		if cooldown_tween:
			if not cooldown_tween.finished.is_connected(_on_cooldown_finished):
				cooldown_tween.finished.connect(_on_cooldown_finished)
		else:
			push_error("Failed to create cooldown tween.")
			_on_cooldown_finished()


func _on_cooldown_finished() -> void:
	cooldown.visible = false
