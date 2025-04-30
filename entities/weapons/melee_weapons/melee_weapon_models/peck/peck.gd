class_name Peck extends MeleeWeapon

func play_attack_animation() -> void:
	if entity_stats.is_player:
		if GameManager.chicken_player && GameManager.chicken_player.animation_tree:
			var animation_tree : AnimationTree = GameManager.chicken_player.animation_tree
			# Fire the OneShot request
			animation_tree.set("parameters/MeleeOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		pass
		# TODO implement peck animation on hennifer
