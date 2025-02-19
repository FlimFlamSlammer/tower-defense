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

@onready var _range_indicator: Node2D = $RangeIndicator
@onready var _range_area: Area2D = $RangeArea
@onready var _upgrades: Node = $Upgrades
@onready var _custom_animations: AnimationPlayer = $CustomAnimations
@onready var _range_animations: AnimationPlayer = $RangeAnimation

## Updates tower visuals and behaviour to match its stats. If param is true, recalculates pathfinding data.
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


func enter_preview_mode() -> void:
	_range_animations.play("show_range")
	_range_animations.advance(_range_animations.current_animation_length)

	process_mode = PROCESS_MODE_DISABLED
	

func set_display_invalid() -> void:
	modulate = Color(1.0, 0.1, 0.1)


func set_display_valid() -> void:
	modulate = Color(1.0, 1.0, 1.0)


func exit_preview_mode() -> void:
	process_mode = PROCESS_MODE_INHERIT


func update_danger_levels() -> void:
	var visited: Dictionary = {}
	var tiles: Array[Vector2i] = [tile_position]

	while tiles.size():
		pass

func _get_tile_danger_level(tile: Vector2i) -> float:
	var dist := tile.distance_to(tile_position)
	var danger: float = stats.range - dist
	return clampf(danger, 0.0, 1.0)