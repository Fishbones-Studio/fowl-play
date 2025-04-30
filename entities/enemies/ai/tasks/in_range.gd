@tool
extends BTCondition

@export var target_var: StringName = &"target"
@export var distance_min: float
@export var distance_max: float

var _min_distance_squared: float
var _max_distance_squared: float


func _generate_name() -> String:
	return "InRange (%d, %d) of %s" % [distance_min, distance_max,
		LimboUtility.decorate_var(target_var)]


func _setup() -> void:
	_min_distance_squared = distance_min * distance_min
	_max_distance_squared = distance_max * distance_max


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		push_warning("InRange: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(target_var), blackboard.get_var(target_var)])
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target.global_position)
	if dist_sq >= _min_distance_squared and dist_sq <= _max_distance_squared:
		return SUCCESS
	else:
		return FAILURE
