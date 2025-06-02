class_name ArenaFlyerResource extends Resource

@export_group("Visual")
## Title that displays in the flyer menu
@export var title : String
## Scene description
@export_multiline var description : String
## Icon that shows up in the flyer scene
@export var icon : Texture2D = preload("uid://2ktdp66oojeb")
@export_group("Enemies")
## Regular enemies
@export var standard_enemy_scenes: Array[PackedScene]
## Boss enemies
@export var boss_enemy_scenes: Array[PackedScene] = []
## Whether to include boss enemies in the arena
@export var include_boss : bool = false
@export_group("Scene")
## How many rounds the arena will have
@export_range(1.0, 5.0, 1.0) var rounds := 2
## Scene where the flyer leads too
@export var scene_to_load : SceneEnums.Scenes

func get_combined_enemy_scenes() -> Array[PackedScene]:
	## Returns a combined array of standard and boss enemy scenes
	var combined_scenes: Array[PackedScene] = standard_enemy_scenes.duplicate()
	if include_boss:
		combined_scenes.append_array(boss_enemy_scenes)
	return combined_scenes
