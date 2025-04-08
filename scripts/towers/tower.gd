class_name Tower
extends Node2D

signal tower_modified()
signal update_paths()
signal tower_clicked(tower: Tower)

const MUTABLE_DATA_PATH: StringName = "res://scenes/towers/crossbow/mutable_data/"

enum Targeting {FIRST, LAST, CLOSE, FAR, STRONG, WEAK}

@export var tower_name: StringName
@export var targeting_options: Array[Targeting] = [Targeting.FIRST, Targeting.LAST, Targeting.CLOSE, Targeting.FAR, Targeting.STRONG, Targeting.WEAK]
@export var price: int = 100

var tile_position: Vector2i
var targeting: int
var current_upgrade: Array[int] = [0, 0]
var selected: bool = false

var stat_multipliers: Dictionary[String, Dictionary]
var stat_adders: Dictionary[String, Dictionary]

var _placed: bool = false

@onready var stats: Dictionary[String, Variant]
@onready var upgrades: Upgrades = $Upgrades

@onready var _mutable_data: MutableData = $MutableData
@onready var _range_indicator: Node2D = $RangeIndicator
@onready var _range_area: Area2D = $RangeArea
@onready var _range_animations: AnimationPlayer = $RangeAnimation
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)
@onready var _click_area: Control = $ClickArea


func _ready() -> void:
	_range_animations.play("show_range")
	modulate = Color(1.0, 1.0, 1.0, 0.4)


func update_danger_levels(group: String) -> void:
	pass


func place() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_placed = true
	modify_tower(true)
	_click_area.mouse_filter = Control.MOUSE_FILTER_STOP


func select() -> void:
	selected = true
	_range_animations.play("show_range")


func deselect() -> void:
	selected = false
	_range_animations.play("hide_range")


## Updates tower stats and appearance, taking into account stat modifiers. If param is true, recalculates pathfinding data.
func modify_tower(p_update_paths: bool) -> void:
	stats = _mutable_data.stats
	for mod in stat_multipliers.values():
		for key in mod.keys():
			if not stats.has(key):
				stats[key] = 0.0
			stats[key] *= mod[key]

	for mod in stat_adders.values():
		for key in mod.keys():
			if not stats.has(key):
				stats[key] = 0.0
			stats[key] += mod[key]

	_range_indicator.scale = Vector2.ONE * stats.range
	tower_modified.emit()

	if p_update_paths:
		update_paths.emit()


## Upgrades the tower by one tier on the specified path. Returns the upgrade cost.
func upgrade_tower(path: int) -> int:
	var tier: int = current_upgrade[path] + 1
	var upgrade: Upgrade = upgrades.get_upgrade(path, tier)

	current_upgrade[path] = tier

	var mutable_data_path: String = MUTABLE_DATA_PATH + str(current_upgrade[0]) + str(current_upgrade[1]) + &".tscn"
	print(mutable_data_path)
	var mutable_data_scene: PackedScene = load(mutable_data_path)
	var new_mutable_data = mutable_data_scene.instantiate()
	new_mutable_data.name = _mutable_data.name

	_mutable_data.queue_free()
	_mutable_data = new_mutable_data
	add_child.call_deferred(new_mutable_data)
	modify_tower.call_deferred(true)

	return upgrade.cost


func enemy_in_range(p_range: float) -> bool:
	_range_area.scale = Vector2.ONE * p_range
	return _range_area.has_overlapping_areas()


func select_to_place() -> void:
	_range_animations.play("show_range")
	_range_animations.advance(_range_animations.current_animation_length)


func set_display_invalid() -> void:
	modulate = Color(1.0, 0.1, 0.1, 0.4)


func set_display_valid() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.4)


func _get_tile_danger_level_multiplier(tile: Vector2i) -> float:
	var dist := tile.distance_to(tile_position)
	## Danger value computed using range and distance.
	var danger: float = ((stats.range - dist - 0.5) * 1.0) + 1.0
	danger = clampf(danger, 0.0, 1.0)
	if danger < 1.0 and danger > 0.0:
		danger = sqrt(danger)
	return danger


func _on_tower_clicked(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		tower_clicked.emit(self)
