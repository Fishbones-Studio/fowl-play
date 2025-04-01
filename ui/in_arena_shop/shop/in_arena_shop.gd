class_name InArenaShop
extends BaseShop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_inventory = false
	prevent_duplicates = false
	title_label.text = "Upgrades"
	# calls baseshop
	super()


func close_ui() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free() 
