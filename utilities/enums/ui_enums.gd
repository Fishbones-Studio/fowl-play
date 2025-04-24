class_name UIEnums

enum UI {
	MAIN_MENU,
	SETTINGS_MENU,
	PAUSE_MENU,
	PLAYER_HUD,
	CHICKEN_INVENTORY,
	POULTRYMAN_SHOP,
	POULTRYMAN_SHOP_CONFIRMATION,
	DEATH_SCREEN,
	IN_ARENA_SHOP,
	PLAYER_DEBUG_MENU,
	ROUND_SCREEN,
	CHICKEN_STATS,
}

const PATHS: Dictionary[UI, String] = {
	UI.MAIN_MENU: "uid://dab0i61vj1n23",
	UI.SETTINGS_MENU: "uid://81fy3yb0j33w",
	UI.PAUSE_MENU: "uid://dnq3em8w064n4",
	UI.PLAYER_HUD: "uid://xhakfqnxgnrr",
	UI.CHICKEN_INVENTORY: "uid://dvkxcgdk0goul",
	UI.POULTRYMAN_SHOP: "uid://bir1j5qouane0",
	UI.POULTRYMAN_SHOP_CONFIRMATION: "uid://da6m7g6ijjyop",
	UI.DEATH_SCREEN: "uid://ba8j8ajmddtai",
	UI.IN_ARENA_SHOP: "uid://djg6luy3rxi23",
	UI.PLAYER_DEBUG_MENU: "uid://bjr4b02aehry4",
	UI.ROUND_SCREEN: "uid://61l26wjx0fux",
	UI.CHICKEN_STATS: "uid://c2vh7na31m8hi",
}


static func ui_to_string(ui: UI) -> String:
	return UI.keys()[ui]
