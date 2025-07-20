class_name Globals
extends Object

const SAVE_PATH: String = "user://"
const MAIN_MENU_SCENE_PATH: String = "res://scenes/map_select.tscn"

enum DamageTypes {TRUE = 0, SHARP = 1, ENERGY = 2, EXPLOSION = 3, ELECTRIC = 4, WALL = 5}


static func get_tile_controller(scene_tree: SceneTree) -> TileController:
	return scene_tree.root.get_child(-1).get_node("TileController")


static func make_custom_tooltip(for_text: String) -> Control:
	var tooltip: Label = preload("res://scenes/ui/shared/tooltip.tscn").instantiate()
	tooltip.text = for_text
	return tooltip
