class_name ArenaFlyerPreviewContainer 
extends VBoxContainer

var _current_item: ArenaFlyerResource

@onready var arena_preview_label: Label = %ArenaPreviewLabel
@onready var arena_preview_icon: TextureRect = %ArenaPreviewIcon
@onready var arena_preview_description: Label = %ArenaPreviewDescription
@onready var boss_label : Label = %BossLabel
@onready var rounds_label : Label = %RoundsLabel

func setup(flyer_resource: ArenaFlyerResource) -> void:
	await get_tree().process_frame

	_current_item = flyer_resource

	arena_preview_label.text = flyer_resource.title
	if flyer_resource.icon:
		arena_preview_icon.texture = flyer_resource.icon
	else:
		arena_preview_icon.texture = null # Or a default placeholder icon

	arena_preview_description.text = flyer_resource.description
	
	if flyer_resource.include_boss:
		boss_label.text = "Bosses: Included"
	else:
		boss_label.text = "Bosses: Not Included"
		
	rounds_label.text = "Rounds: %s" % flyer_resource.rounds
