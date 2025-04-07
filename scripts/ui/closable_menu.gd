class_name ClosableMenu
extends Control

var is_open: bool = false

var open_position: ControlPosition
var closed_position: ControlPosition

var on_open: Callable
var on_close: Callable

func _ready() -> void:
	open_position = ControlPosition.new(self)
	closed_position = ControlPosition.new(self)


func open(instant: bool = false) -> void:
	if on_open:
		on_open.call()
	if instant:
		open_position.set_node_position(self)
	else:
		open_position.tween_node_position(
			self,
			0.25,
			Tween.EASE_IN_OUT,
			Tween.TRANS_CUBIC
		)
	is_open = true

func close(instant: bool = false) -> void:
	if on_close:
		on_close.call()
	if instant:
		closed_position.set_node_position(self)
	else:
		closed_position.tween_node_position(
			self,
			0.15,
			Tween.EASE_IN,
			Tween.TRANS_CUBIC
		)
	is_open = false


func toggle_visibility() -> void:
	if is_open:
		close()
	else:
		open()
