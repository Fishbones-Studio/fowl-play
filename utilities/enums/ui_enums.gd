class_name UIEnums

enum UI {
	MAIN_MENU,
	SETTINGS_MENU,
	PAUSE_MENU,
	PLAYER_HUD,
	CHICKEN_INVENTORY,
	POULTRYMAN_SHOP,
	POULTRYMAN_SHOP_CONFIRMATION,
	ARENAS,
	DEATH_SCREEN,
	VICTORY_SCREEN,
	IN_ARENA_SHOP,
	PLAYER_DEBUG_MENU,
	ROUND_SCREEN,
	LOADING_SCREEN,
	CHICKEN_STATS,
	FORFEIT_POPUP,
	REBIRTH_SHOP,
	DIALOGUE_BALLOON,
	DELETE_SAVE_POPUP,
	CONTROL_OVERVIEW,
	QUIT_GAME_POPUP,
	REBIRTH_SHOP_RESET_STATS_POPUP,
	REBIRTH_SHOP_CONFIRMATION,
	NULL ## Specific value for when no ui should be loaded
}

## Ui uid pair
const PATHS: Dictionary[UI, String] = {
	UI.MAIN_MENU: "uid://dab0i61vj1n23",
	UI.SETTINGS_MENU: "uid://81fy3yb0j33w",
	UI.PAUSE_MENU: "uid://dnq3em8w064n4",
	UI.PLAYER_HUD: "uid://xhakfqnxgnrr",
	UI.CHICKEN_INVENTORY: "uid://dvkxcgdk0goul",
	UI.POULTRYMAN_SHOP: "uid://bir1j5qouane0",
	UI.POULTRYMAN_SHOP_CONFIRMATION: "uid://c5dp7ogav2j86",
	UI.ARENAS: "uid://n7ew83nu7xpl",
	UI.DEATH_SCREEN: "uid://ba8j8ajmddtai",
	UI.VICTORY_SCREEN: "uid://sjvml6sgskxh",
	UI.IN_ARENA_SHOP: "uid://djg6luy3rxi23",
	UI.PLAYER_DEBUG_MENU: "uid://bjr4b02aehry4",
	UI.ROUND_SCREEN: "uid://61l26wjx0fux",
	UI.LOADING_SCREEN: "uid://cu2ima27whcct",
	UI.CHICKEN_STATS: "uid://c2vh7na31m8hi",
	UI.FORFEIT_POPUP: "uid://f7nhygrw6kbd",
	UI.REBIRTH_SHOP: "uid://dmgeue4l6fj4f",
	UI.DIALOGUE_BALLOON: "uid://cfg06xxv1turn",
	UI.DELETE_SAVE_POPUP: "uid://d1gtrx56xraue",
	UI.CONTROL_OVERVIEW: "uid://by11faodnc0sv",
	UI.QUIT_GAME_POPUP: "uid://dx5jf0y4udv81",
	UI.REBIRTH_SHOP_RESET_STATS_POPUP: "uid://brdl7fh3unwoc",
	UI.REBIRTH_SHOP_CONFIRMATION: "uid://cb46h0sdgyhl5",
}

## List of UI elements that should block game input outside of the UI
const UI_BLOCK_GAME_INPUT: Array[UI] = [
	UI.SETTINGS_MENU,
	UI.PAUSE_MENU,
	UI.CHICKEN_INVENTORY,
	UI.POULTRYMAN_SHOP,
	UI.POULTRYMAN_SHOP_CONFIRMATION,
	UI.DIALOGUE_BALLOON,
	UI.IN_ARENA_SHOP,
	UI.ARENAS,
	UI.ROUND_SCREEN,
	UI.LOADING_SCREEN,
	UI.REBIRTH_SHOP,
	UI.DEATH_SCREEN,
	UI.CHICKEN_STATS,
	UI.FORFEIT_POPUP
]

## List of UI elements that should have mouse captured when active
const UI_MOUSE_CAPTURED: Array[UI] = [
	UI.PLAYER_HUD,
	UI.CONTROL_OVERVIEW,
	UI.ROUND_SCREEN,
	UI.DEATH_SCREEN,
	UI.VICTORY_SCREEN
]

const UI_EXCEMPT_VISIBLE_CHECK: Array[UI] =  [
  UI.PLAYER_HUD,
  UI.CONTROL_OVERVIEW,
  UI.PAUSE_MENU
]

static func ui_to_string(ui: UI) -> String:
	return UI.keys()[ui]
