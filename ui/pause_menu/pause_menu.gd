extends Control

var footer: PanelContainer
var game_logo_container: MarginContainer


func setup(params: Dictionary = {}) -> void:
	init()
	load_footer()
	setup_entered_and_exit_transitions()


# TODO: Make this modular
func load_footer():
	# Position footer below the screen
	footer.position.y += footer.size.y
	
	# Create tween to slide footer up from bottom of the screen
	var tween = create_tween()
	tween.tween_property(footer, "position:y", 592, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func scale(node: Control, scale_xy: Vector2, duration: float = 0.2, 
	transition: Tween.TransitionType = Tween.TRANS_CUBIC, 
	ease: Tween.EaseType = Tween.EASE_OUT) -> void:
	var tween = node.create_tween()
	tween.tween_property(node, "scale", scale_xy, duration).set_trans(transition).set_ease(ease)


func setup_entered_and_exit_transitions():
	var buttons = find_children("", "Button", true)  # Find all Button nodes
	
	for button in buttons:
		print("Found button:", button.name)
	
	for button in buttons:
		button.mouse_entered.connect(func(): scale(button, Vector2(1.1, 1.1)))
		button.mouse_exited.connect(func(): scale(button, Vector2(1.0, 1.0)))
	
	game_logo_container.mouse_entered.connect(func(): scale(game_logo_container, Vector2(1.1, 1.1)))
	game_logo_container.mouse_exited.connect(func(): scale(game_logo_container, Vector2(1.1, 1.1)))


func init() -> void:
	footer = %Footer
	game_logo_container = %GameLogoContainer
