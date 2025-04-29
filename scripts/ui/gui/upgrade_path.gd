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
		_cost_label.text = str(val)

var tier: int:
	set(val):
		tier = val
		for panel: Panel in _tier_indicator.get_children():
			if panel.name.to_int() <= val:
				panel.add_theme_stylebox_override(&"panel", PANEL_ON)
			else:
				panel.add_theme_stylebox_override(&"panel", PANEL_OFF)

var description: String:
	set(val):
		description = val
		tooltip_text = val
		_button.tooltip_text = val

var disabled: bool = false:
	set(val):
		disabled = val
		if val:
			_cost_label.text = "Locked"
		else:
			cost = cost # force update cost label
		_button.disabled = val
			

@onready var _label: Label = %Label
@onready var _cost_label: Label = %PriceLabel
@onready var _tier_indicator: VBoxContainer = %TierIndicator
@onready var _button: Button = %Button

func _make_custom_tooltip(for_text: String) -> Control:
	return Globals.make_custom_tooltip(for_text)


func _on_button_pressed() -> void:
	button_pressed.emit()
