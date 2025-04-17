extends BaseDatabase


static func _load_resources() -> Array[BaseResource]:
	return load_items("res://ui/in_arena_shop/resources/")
