class_name Peck extends MeleeWeapon

func play_attack_animation() -> void:
	var animation_tree : AnimationTree
	if entity_stats.is_player:
		if GameManager.chicken_player && GameManager.chicken_player.animation_tree:
			animation_tree  = GameManager.chicken_player.animation_tree
	else:
		if GameManager.current_enemy && GameManager.current_enemy.animation_tree:
			animation_tree = GameManager.current_enemy.animation_tree
		
	if animation_tree:
		# Fire the OneShot request
		animation_tree.set("parameters/MeleeOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
