class_name PauseMenu
extends ScreenMenu

func _ready() -> void:
	var buttons: Array[Node] = get_tree().get_nodes_in_group("pause_menu_buttons")
	for button: Button in buttons:
		button.pressed.connect(open)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close()
