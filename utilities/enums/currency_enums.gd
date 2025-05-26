class_name CurrencyEnums
extends Node

enum CurrencyTypes {
	PROSPERITY_EGGS,
	FEATHERS_OF_REBIRTH,
}

static func currency_type_to_string(currencyType : CurrencyTypes, short := false) -> String:
	var currency_string: String = CurrencyTypes.keys()[currencyType]
	if short:
		var parts = currency_string.split("_")
		var short_parts = []
		for part in parts:
			if part.length() > 0:
				short_parts.append(part[0])
		return ".".join(short_parts) + "."
	return currency_string.capitalize()
