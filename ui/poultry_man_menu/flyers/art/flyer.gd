extends Focusable3D


func focus() -> void:
	if is_focused:
		return

	for item in focusable_objects:
		var material: Material = item.get_active_material(0)
		material.set("shader_parameter/highlight", true)

	super()


func unfocus() -> void:
	if not is_focused:
		return

	for item in focusable_objects:
		var material: Material = item.get_active_material(0)
		material.set("shader_parameter/highlight", false)

	super()
