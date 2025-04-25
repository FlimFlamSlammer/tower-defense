class_name ResourceDisplay
extends PanelContainer

var value: Variant:
	set(val):
		_label.text = val
		return val

@onready var _label: Label = get_child(0).get_child(0).get_child(1)
