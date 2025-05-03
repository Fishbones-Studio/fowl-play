extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	SignalManager.boss_appeared.connect(_on_boss_appeared)



func _on_boss_appeared(visible: bool) -> void:
	# set visible when boss appears
	self.visible = visible
