class_name TowerButton
extends Button

signal tower_button_pressed(tower_scene: PackedScene)

@export var tower_scene: PackedScene

func _on_button_pressed() -> void:
	tower_button_pressed.emit(tower_scene)
