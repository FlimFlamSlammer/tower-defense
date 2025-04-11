class_name Carousel
extends HBoxContainer

signal option_changed(val: int)

var _option_names: Array[StringName]
var _current_index: int

@onready var _label: Label = $Label

func set_options(options: Array[StringName]):
	_option_names = options


func set_option(index: int):
	_current_index = index
	_update_label()


func _change_index(amount: int):
	_current_index = wrapi(_current_index + amount, 0, _option_names.size())
	option_changed.emit(_current_index)
	_update_label()


func _update_label():
	_label.text = _option_names[_current_index]
