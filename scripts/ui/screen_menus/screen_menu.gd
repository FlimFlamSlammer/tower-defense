class_name ScreenMenu
extends Control

signal opened()
signal closed()

@onready var _backdrop: CanvasItem = $Backdrop


func open() -> void:
	_backdrop.self_modulate = Color(1, 1, 1, 0)
	show()

	var tween: Tween = create_tween()
	tween.tween_property(_backdrop, "self_modulate", Color(1, 1, 1, 1), 0.07).set_ease(Tween.EASE_OUT)

	opened.emit()


func close() -> void:
	hide()
	closed.emit()
