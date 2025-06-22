class_name NumberUtils

const UNITS = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
const TEENS = ["Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"]
const TENS = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"]


static func to_words(number: int) -> String:
	if number < 0:
		return "Minus " + to_words(-number)
	if number < 10:
		return UNITS[number]
	if number < 20:
		return TEENS[number - 10]
	if number < 100:
		return TENS[int(number / 10.0)] + ("-" + UNITS[number % 10] if number % 10 != 0 else "")
	if number < 1000:
		return UNITS[int(number / 100.0)] + " Hundred" + (" and " + to_words(number % 100)) if number % 100 != 0 else ""
	return "Number too large"
