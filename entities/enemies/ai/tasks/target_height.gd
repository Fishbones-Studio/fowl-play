@tool
extends BTCondition

@export var target_var: StringName = &"target" # Blackboard variable name
@export var comparison: ComparisonEnums.ComparisonType = ComparisonEnums.ComparisonType.GREATER_THAN_OR_EQUAL
@export var height_threshold: float = 4.5
@export var use_relative: bool = true  # Compare to agent's height or absolute world Y
@export var target_on_floor: bool = true

var _initial_height: float
var _condition_met: bool


func _generate_name() -> String:
	var comp_text: String
	match comparison:
		ComparisonEnums.ComparisonType.LESS_THAN:
			comp_text = "<"
		ComparisonEnums.ComparisonType.GREATER_THAN:
			comp_text = ">"
		ComparisonEnums.ComparisonType.EQUAL:
			comp_text = "=="
		ComparisonEnums.ComparisonType.LESS_THAN_OR_EQUAL:
			comp_text = "<="
		ComparisonEnums.ComparisonType.GREATER_THAN_OR_EQUAL:
			comp_text = ">="

	return "Height ➜ %s %s %.1f" % [LimboUtility.decorate_var(target_var), comp_text, height_threshold]


func _enter() -> void:
	if use_relative:
		_initial_height = agent.global_position.y


func _tick(_delta: float) -> Status:
	if not agent.visible:
		return FAILURE

	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var height_to_check: float
	if use_relative:
		height_to_check = target.global_position.y - agent.global_position.y
	else:
		height_to_check = target.global_position.y

	match comparison:
		ComparisonEnums.ComparisonType.LESS_THAN:
			_condition_met = height_to_check < height_threshold
		ComparisonEnums.ComparisonType.GREATER_THAN:
			_condition_met = height_to_check > height_threshold
		ComparisonEnums.ComparisonType.EQUAL:
			_condition_met = is_equal_approx(height_to_check, height_threshold)
		ComparisonEnums.ComparisonType.LESS_THAN_OR_EQUAL:
			_condition_met = height_to_check <= height_threshold
		ComparisonEnums.ComparisonType.GREATER_THAN_OR_EQUAL:
			_condition_met = height_to_check >= height_threshold

	if target_on_floor:
		_condition_met = _condition_met and target.is_on_floor()

	return SUCCESS if _condition_met else FAILURE
