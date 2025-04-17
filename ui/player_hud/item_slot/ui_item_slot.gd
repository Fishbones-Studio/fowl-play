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

@onready var active_indicator: ColorRect = $ActiveIndicator
@onready var item_image: TextureRect = $ItemImage
@onready var item_background: ColorRect = $ItemBackground
@onready var cooldown: ColorRect = $Cooldown
var cooldown_tween: Tween # Removed @onready, initialize as needed

func _ready() -> void:
	# Apply colors
	active_indicator.color = active_indicator_colour if active_indicator_colour else active_indicator.color
	item_background.color = item_background_colour if item_background_colour else item_background.color
	cooldown.color = cooldown_colour if cooldown_colour else cooldown.color

	# Start hidden
	cooldown.visible = false
	active_indicator.visible = false

	_update_item_visuals()

func _update_item_visuals() -> void:
	if item_image and item:
		item_image.texture = item.icon

func start_cooldown(duration: float) -> void:
	# Stop and discard any existing tween safely
	if cooldown_tween and cooldown_tween.is_valid():
		cooldown_tween.kill()
	# cooldown_tween reference will be overwritten below

	# Ensure the node is ready for tweening
	if not cooldown or not cooldown.is_inside_tree():
		push_warning("Cooldown node is not ready for tweening.")
		return

	# Reset cooldown bar to full size
	cooldown.size = item_background.size
	cooldown.visible = true

	# Create a new tween
	cooldown_tween = self.create_tween()
	TweenManager.create_size_tween(
		cooldown_tween, 
		cooldown, 
		"y",      
		0.0,      
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)

	# Connect the finished signal *only if* the tween was created successfully
	if cooldown_tween:
		cooldown_tween.finished.connect(_on_cooldown_finished)
	else:
		# Handle the case where tween creation failed in the manager
		push_error("Failed to create cooldown tween via TweenManager.")
		_on_cooldown_finished() # Fallback: hide bar immediately

func _on_cooldown_finished() -> void:
	cooldown.visible = false
	cooldown_tween = null
