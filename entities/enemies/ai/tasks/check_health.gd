@tool
extends BTCondition

enum ComparisonType {
	LESS_THAN,
	GREATER_THAN,
	EQUAL,
	LESS_THAN_OR_EQUAL,
	GREATER_THAN_OR_EQUAL
}

@export var comparison: ComparisonType = ComparisonType.LESS_THAN
@export var threshold: float = 0.0
@export var use_percentage: bool = false

var _current_health: float
var _condition_met: bool

func _generate_name() -> String:
	var comp_text: String
	match comparison:
		ComparisonType.LESS_THAN:
			comp_text = "<"
		ComparisonType.GREATER_THAN:
			comp_text = ">"
		ComparisonType.EQUAL:
			comp_text = "=="
		ComparisonType.LESS_THAN_OR_EQUAL:
			comp_text = "<="
		ComparisonType.GREATER_THAN_OR_EQUAL:
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
		ComparisonType.LESS_THAN:
			_condition_met = _current_health < threshold
		ComparisonType.GREATER_THAN:
			_condition_met = _current_health > threshold
		ComparisonType.EQUAL:
			_condition_met = is_equal_approx(_current_health, threshold)
		ComparisonType.LESS_THAN_OR_EQUAL:
			_condition_met = _current_health <= threshold
		ComparisonType.GREATER_THAN_OR_EQUAL:
			_condition_met = _current_health >= threshold
	
	return SUCCESS if _condition_met else FAILURE
