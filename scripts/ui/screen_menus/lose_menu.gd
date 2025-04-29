class_name LoseMenu
extends ScreenMenu

signal restart_requested()
signal exit_requested()
signal retry_requested()

@onready var _pause_menu_button: Button = get_tree().get_nodes_in_group("pause_menu_buttons")[-1]

func _ready() -> void:
	_pause_menu_button.pressed.connect(open)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close()


func _on_retry_button_pressed() -> void:
	retry_requested.emit()


func _on_restart_button_pressed() -> void:
	Events.alert_requested.emit("Restart the game?\n(All progress in this game will be lost)", ["Cancel", "Restart"], [ func() -> void: , restart_requested.emit])


func _on_exit_button_pressed() -> void:
	Events.alert_requested.emit("Exit the game?\n(Progress will be saved)", ["Cancel", "Exit"], [ func() -> void: , exit_requested.emit])
