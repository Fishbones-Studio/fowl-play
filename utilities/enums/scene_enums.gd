class_name SceneEnums

enum Scenes {
	TRAINING_AREA,
	FLYING_ARENA,
	SEWER_ARENA,
	POULTRY_MAN_MENU
}

## Scene, uid pair
const PATHS: Dictionary[Scenes, String] = {
	Scenes.TRAINING_AREA: "uid://c3ftt1f5ca2ju",
	Scenes.FLYING_ARENA: "uid://bv7d7vi3oo751",
	Scenes.SEWER_ARENA: "uid://bhnqi4fnso1hh",
	Scenes.POULTRY_MAN_MENU: "uid://21r458rvciqo"
}

static func scene_to_string(scene: Scenes) -> String:
	return Scenes.keys()[scene].capitalize()
