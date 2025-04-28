class_name WinMenu
extends ScreenMenu

signal restart_requested()
signal exit_requested()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_exit_button_pressed() -> void:
	exit_requested.emit()
