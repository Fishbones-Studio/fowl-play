class_name CurrencyEnums
extends Node

enum CurrencyTypes {
	PROSPERITY_EGGS,
	FEATHERS_OF_REBIRTH,
}


static func type_to_string(currency_type: CurrencyTypes) -> String:
	return CurrencyTypes.keys()[currency_type].capitalize()
