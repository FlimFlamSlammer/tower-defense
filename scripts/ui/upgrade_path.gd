class_name UpgradePath
extends Container

signal button_pressed()

const PANEL_ON: StyleBox = preload("uid://i4csefihyled")
const PANEL_OFF: StyleBox = preload("uid://bc4s26ts4ee5t")

var upgrade_name: String:
	set(val):
		upgrade_name = val
		_label.text = val

var cost: int:
	set(val):
		cost = val
		_price_label.text = str(val)

var tier: int:
	set(val):
		tier = val
		for panel: Panel in _tier_indicator.get_children():
			if panel.name.to_int() <= val:
				panel.add_theme_stylebox_override(&"panel", PANEL_ON)
			else:
				panel.add_theme_stylebox_override(&"panel", PANEL_OFF)

@onready var _label: Label = %Label
@onready var _price_label: Label = %PriceLabel
@onready var _tier_indicator: VBoxContainer = %TierIndicator

func _on_button_pressed() -> void:
	button_pressed.emit()
