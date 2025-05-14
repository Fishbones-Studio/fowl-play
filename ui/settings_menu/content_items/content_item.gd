class_name ContentItem
extends Control


func _set_neighbors_for(item: Control) -> void:
	item.focus_neighbor_top = focus_neighbor_top
	item.focus_neighbor_right = focus_neighbor_right
	item.focus_neighbor_bottom = focus_neighbor_bottom
	item.focus_neighbor_left = focus_neighbor_left


func _toggle_active(panel: Control, value: bool) -> void:
	panel.theme_type_variation = &"SettingsContentPanel" if value else &"SettingsContentPanelInactive"
