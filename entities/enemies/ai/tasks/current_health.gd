@tool
extends BTCondition

@export var comparison: ComparisonEnums.ComparisonType = ComparisonEnums.ComparisonType.LESS_THAN
@export var threshold: float = 0.0
@export var use_percentage: bool = false

var _current_health: float
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

	var value_text: String

	if use_percentage:
		value_text = "%d%%" % threshold
	else:
		value_text = "%.1f" % threshold

	return "Health %s %s" % [comp_text, value_text]


func _tick(_delta: float) -> Status:
	if use_percentage:
		_current_health = agent.stats.current_health / agent.stats.max_health * 100.0
	else:
		_current_health = agent.stats.current_health

	match comparison:
		ComparisonEnums.ComparisonType.LESS_THAN:
			_condition_met = _current_health < threshold
		ComparisonEnums.ComparisonType.GREATER_THAN:
			_condition_met = _current_health > threshold
		ComparisonEnums.ComparisonType.EQUAL:
			_condition_met = is_equal_approx(_current_health, threshold)
		ComparisonEnums.ComparisonType.LESS_THAN_OR_EQUAL:
			_condition_met = _current_health <= threshold
		ComparisonEnums.ComparisonType.GREATER_THAN_OR_EQUAL:
			_condition_met = _current_health >= threshold
	
	return SUCCESS if _condition_met else FAILURE
