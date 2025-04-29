class_name Peck extends MeleeWeapon

func play_attack_animation() -> void:
	if entity_stats.is_player:
		if GameManager.chicken_player && GameManager.chicken_player.animation_tree:
			var animation_tree : AnimationTree = GameManager.chicken_player.animation_tree
			#animation_tree.get("parameters/MovementStateMachine/playback").travel("Attack")
	else:
		pass
		# TODO implement peck animation on hennifer
