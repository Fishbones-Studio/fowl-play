extends MeleeWeapon


func weapon_hit_effect(body: CharacterBody3D) -> void:
	var model: Node3D = body.model
	var tween: Tween = model.create_tween()

	TweenManager.create_scale_tween(tween, model, Vector3(1.5, 0.5, 1.5), 0.4)
	TweenManager.create_scale_tween(tween, model, Vector3(0.8, 1.2, 0.8), 0.15)
	TweenManager.create_scale_tween(tween, model, Vector3(1.1, 0.9, 1.1), 0.15)
	TweenManager.create_scale_tween(tween, model, Vector3(1.0, 1.0, 1.0), 0.1)
