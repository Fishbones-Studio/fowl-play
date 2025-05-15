class_name CurrencyOverview extends CenterContainer

@export var column_one_title: String = "Currency"
@export var column_two_title: String = "Amount"
## Int should be the change. So if the user lost 300, int will be -300
@export var label_amount_dictionary: CurrencyOverviewDict = CurrencyOverviewDict.new({})

@onready var label_container: GridContainer = %LabelContainer

func _ready() -> void:
	if !label_amount_dictionary.currency_dict.is_empty():
		update_label_container()
	

func _add_labels_to_container() -> void:
	var column_one_label: Label = Label.new()
	var column_two_label: Label = Label.new()
	column_one_label.text = column_one_title
	column_two_label.text = column_two_title
	label_container.add_child(column_one_label)
	label_container.add_child(column_two_label)

	for key in label_amount_dictionary.currency_dict.keys():
		var label: Label = Label.new()
		var amount: Label = Label.new()
		label.text = str(key)
		amount.text = str(label_amount_dictionary.currency_dict[key])
		label_container.add_child(label)
		label_container.add_child(amount)

func update_label_container() -> void:
	for child in label_container.get_children():
		child.queue_free()
	_add_labels_to_container()
