class_name Globals
extends Object

const TILE_CONTROLLER_PATH: NodePath = "/root/Map/MainTileMap"

const TowerGroups: Dictionary[StringName, StringName] = {
	ATTACKING = "attacking_towers",
	SETUP = "setup_towers",
	SUPPORT = "support_towers",
}

enum DamageTypes {NORMAL = 0, SHARP = 1, ENERGY = 2, EXPLOSION = 3, ELECTRIC = 4}
