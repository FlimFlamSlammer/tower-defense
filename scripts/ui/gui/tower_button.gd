class_name TowerButton
extends Button

const TOOLTIP_TEMPLATE: String = "{name}\n{description}\nCosts {cost}"

signal tower_button_pressed(tower_scene: PackedScene)

@export var tower_scene: PackedScene

func _ready() -> void:
	var tower: Tower = tower_scene.instantiate()
	tooltip_text = TOOLTIP_TEMPLATE.format({
		name = tower.tower_name,
		description = tower.description,
		cost = tower.cost
	})
	
	tower.free()


func _make_custom_tooltip(for_text: String) -> Control:
	return Globals.make_custom_tooltip(for_text)


func _on_button_pressed() -> void:
	tower_button_pressed.emit(tower_scene)
