class_name Tower
extends Node2D

signal tower_modified()
signal update_paths()

enum POSS_TGT_OPTS {FIRST, LAST, CLOSE, FAR, STRONG, WEAK}

@export var targeting_options: Array[POSS_TGT_OPTS] = [POSS_TGT_OPTS.FIRST, POSS_TGT_OPTS.LAST, POSS_TGT_OPTS.CLOSE, POSS_TGT_OPTS.FAR, POSS_TGT_OPTS.STRONG, POSS_TGT_OPTS.WEAK]
@export var stats: Dictionary = {
	"range" = 4.0,
	"damage" = 1.0,
	"fire_rate" = 1.0,
	"pierce" = 1,
}

var tile_position: Vector2i
var targeting: int
var current_upgrade: Array[int] = [0, 0]

@onready var _range_indicator: Node2D = $RangeIndicator
@onready var _upgrades: Node = $Upgrades

## Updates tower visuals and behaviour to match its stats. If param is true, recalculates pathfinding data.
func modify_tower(p_update_paths: bool) -> void:
	_range_indicator.scale = Vector2(stats.range, stats.range)
	tower_modified.emit()

	if p_update_paths:
		update_paths.emit()

		
## Upgrades the tower by one tier on the specified path. Returns the upgrade cost.
func upgrade_tower(path: int) -> int:
	var tier: int = current_upgrade[path] + 1
	var upgrade := _upgrades.get_child(path).get_child(tier) as Upgrade

	if not upgrade:
		print_debug("T", tier, " upgrade from path ", path, " not found, Skipping...")
		return 0

	current_upgrade[path] = tier

	for stat in upgrade.stats.keys():
		stats[stat] *= upgrade.stats[stat]

	modify_tower(true)

	return upgrade.cost