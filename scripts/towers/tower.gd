class_name Tower
extends Node2D

signal tower_modified()
signal update_paths()

enum Targeting {FIRST, LAST, CLOSE, FAR, STRONG, WEAK}

@export var targeting_options: Array[Targeting] = [Targeting.FIRST, Targeting.LAST, Targeting.CLOSE, Targeting.FAR, Targeting.STRONG, Targeting.WEAK]
@export var stats: Dictionary = {
	"range" = 4.0,
	"damage" = 1.0,
	"fire_rate" = 1.0,
	"pierce" = 1,
}

var tile_position: Vector2i
var targeting: int
var current_upgrade: Array[int] = [0, 0]
var placed: bool = false

@onready var _range_indicator: Node2D = $RangeIndicator
@onready var _range_area: Area2D = $RangeArea
@onready var _upgrades: Node = $Upgrades
@onready var _custom_animations: AnimationPlayer = $CustomAnimations
@onready var _range_animations: AnimationPlayer = $RangeAnimation
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)


func _process(delta: float) -> void:
	if (not placed):
		return


func _update_danger_levels(group: String) -> void:
	pass


## Updates tower range circle to match its stats. If param is true, recalculates pathfinding data.
func modify_tower(p_update_paths: bool) -> void:
	_range_indicator.scale = Vector2.ONE * stats.range
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


func enemy_in_range(p_range: float) -> bool:
	_range_area.scale = Vector2.ONE * p_range
	return _range_area.has_overlapping_areas()


func select_to_place() -> void:
	_range_animations.play("show_range")
	_range_animations.advance(_range_animations.current_animation_length)
	

func set_display_invalid() -> void:
	modulate = Color(1.0, 0.1, 0.1)


func set_display_valid() -> void:
	modulate = Color(1.0, 1.0, 1.0)


func _get_tile_danger_level_multiplier(tile: Vector2i) -> float:
	var dist := tile.distance_to(tile_position)
	var danger: float = stats.range - dist
	return clampf(danger, 0.0, 1.0)