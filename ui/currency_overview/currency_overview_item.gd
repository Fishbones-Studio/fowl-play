class_name CurrencyOverviewItem
extends Control

@export var icons: Dictionary[CurrencyEnums.CurrencyTypes, CompressedTexture2D] = {
	CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS: null,
	CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH: null,
}

@onready var icon: TextureRect = %Icon
@onready var amount: Label = %AmountLabel
@onready var label: Label = $VBoxContainer/Label
