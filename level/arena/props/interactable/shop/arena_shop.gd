# Arena 
extends InteractBox

func interact() -> void:
	if UIEnums.UI.IN_ARENA_SHOP in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.IN_ARENA_SHOP)
