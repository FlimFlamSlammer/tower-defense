class_name WallButton
extends Button

signal wall_button_pressed(wall_scene: PackedScene)

@export var wall_scene: PackedScene

func _on_button_pressed() -> void:
	wall_button_pressed.emit(wall_scene)
