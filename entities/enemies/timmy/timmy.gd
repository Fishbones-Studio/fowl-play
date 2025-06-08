extends Enemy


func _physics_process(delta: float) -> void:
	if is_immobile:
		velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	move_and_slide()
