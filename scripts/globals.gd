class_name Globals
extends Object

const TILE_CONTROLLER_PATH: NodePath = "/root/Map/MainTileMap"
const SAVE_PATH: String = "user://"

enum DamageTypes {NORMAL = 0, SHARP = 1, ENERGY = 2, EXPLOSION = 3, ELECTRIC = 4}


static func get_tile_controller(scene_tree: SceneTree) -> TileController:
	return scene_tree.root.get_child(-1).get_node("TileController")
