class_name CurrencyEnums
extends Node

enum CurrencyTypes {
	PROSPERITY_EGGS,
	FEATHERS_OF_REBIRTH,
}


static func type_to_string(currency_type: CurrencyTypes, short:=false) -> String:
	var currency_string: String = CurrencyTypes.keys()[currency_type]
	if short:
		var parts: PackedStringArray    = currency_string.split("_")
		var short_parts: Array[Variant] = []
		for part in parts:
			if part.length() > 0:
				short_parts.append(part[0])
		return ".".join(short_parts) + "."
	return currency_string.capitalize()
