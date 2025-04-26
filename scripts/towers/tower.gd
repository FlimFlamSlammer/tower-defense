class_name Tower
extends Node2D

signal tower_modified() ## Emits when the tower's update function is called.
signal tower_sold()
signal tower_clicked() ## Emits when the Tower is clicked by the player.
signal money_requested(amount: int, spend: bool, cb: Callable) ## Emits when the tower requests an action that uses money. Call param cb to confirm the action.

const Targeting: Dictionary[StringName, StringName] = {
	FIRST = "First",
	LAST = "Last",
	CLOSE = "Close",
	FAR = "Far",
	STRONG = "Strong",
	WEAK = "Weak",
}

const Groups: Dictionary[StringName, StringName] = {
	ALL = "towers",
	ATTACKING = "attacking_towers",
	SETUP = "setup_towers",
	SUPPORT = "supporting_towers",
	USES_BULLET = "uses_bullet_towers",
}

@export var tower_name: StringName
@export var targeting_options: Array[StringName] = [Targeting.FIRST, Targeting.LAST, Targeting.CLOSE, Targeting.FAR, Targeting.STRONG, Targeting.WEAK]
@export var cost: int

var tile_controller: TileController

var tile_position: Vector2i:
	set(val):
		tile_position = val
		position = tile_controller.map_to_local(val)

var targeting: StringName = Targeting.FIRST ## The targeting option that the Tower is currently using.
var current_upgrade: Array[int] = [0, 0]
var selected: bool = false

var _status_effects: Dictionary[StringName, TowerStatusEffect]
var _placed: bool = false

@onready var stats: Dictionary[StringName, Variant]
@onready var upgrades: Upgrades = $Upgrades

@onready var _mutable_data: MutableData = $MutableData
@onready var _range_indicator: Node2D = $RangeIndicator
@onready var _range_area: Area2D = $RangeArea
@onready var _range_animations: AnimationPlayer = $RangeAnimation
@onready var _click_area: Control = $ClickArea


func _ready() -> void:
	_range_animations.play("show_range")


func _update_tile_danger_levels(group: StringName, current_danger_level: float, danger_mult: float, immunities: Array[Globals.DamageTypes]) -> float:
	return current_danger_level


## Updates the danger levels of all [PathTiles] in range of the tower.
func update_danger_levels(group: StringName, immunities: Array[Globals.DamageTypes]) -> void:
	if not group in get_groups() or not _placed: return

	_run_for_tiles_in_range(func(tile: Tile, overlap_ratio: float) -> void:
		var path_tile := tile as PathTile
		if path_tile:
			path_tile.danger_level = _update_tile_danger_levels(group, path_tile.danger_level, overlap_ratio, immunities)
	)


## Places the tower, updating some functionalities.
func place() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_placed = true
	update_status_effects()
	_click_area.mouse_filter = Control.MOUSE_FILTER_STOP


func save() -> Dictionary[StringName, Variant]:
	var save_dict: Dictionary[StringName, Variant] = {
		scene_path = scene_file_path,
		position = tile_position,
		upgrade = current_upgrade,
		targeting = targeting,
	}
	return save_dict


func load(data: Dictionary[StringName, Variant]) -> void:
	for i: int in range(data.upgrade.size()):
		current_upgrade[i] = data.upgrade[i] as int

	var mutable_data_scene: PackedScene = _get_current_mutable_data_scene()

	var new_mutable_data: MutableData = mutable_data_scene.instantiate()
	new_mutable_data.name = _mutable_data.name

	_mutable_data.queue_free()
	_mutable_data = new_mutable_data
	add_child.call_deferred(new_mutable_data)
	update_status_effects.call_deferred()

	targeting = data.targeting

	_range_animations.play("RESET")


## Marks the tower as selected, showing its range circle.
func select() -> void:
	selected = true
	_range_animations.play("show_range")


## Marks the tower as deselected, hiding its range circle.
func deselect() -> void:
	selected = false
	_range_animations.play("hide_range")


func sell() -> void:
	var sell_value: float = 0.333
	if "sell_value" in stats:
		sell_value *= stats.sell_value

	money_requested.emit(-cost * sell_value, true, Utils.null_callable)

	queue_free()
	tower_sold.emit()


## Applies status effects to the tower and runs any functions that depend on the tower's stats.
func update_status_effects() -> void:
	stats = _mutable_data.stats.duplicate()
	for effect: TowerStatusEffect in _status_effects.values():
		effect.apply(stats)

	update_range_circle()

	if _placed: tower_modified.emit()


## Resizes the range circle based on range stat.
func update_range_circle() -> void:
	_range_indicator.scale = Vector2.ONE * stats.range


## Reparents the TowerStatusEffect to the Tower where the function was called. Use duplicate() to preserve the TowerStatusEffect.
func apply_status_effect(effect: TowerStatusEffect, p_update: bool = true) -> bool:
	if effect.id in _status_effects:
		if _status_effects[effect.id].priority >= effect.priority:
			effect.queue_free()
			return false
		else:
			remove_status_effect(effect.id, false)

	effect.expired.connect(remove_status_effect.bind(effect.id))

	_status_effects[effect.id] = effect
	if effect.get_parent():
		effect.reparent(self)
	else:
		add_child(effect)

	if p_update:
		update_status_effects()

	return true


func clear_persistent_status_effects() -> void:
	for effect: TowerStatusEffect in _status_effects.values():
		if effect.persistent:
			_status_effects[effect.id].queue_free()
			_status_effects.erase(effect.id)


func remove_status_effect(id: StringName, p_update: bool = true) -> void:
	_status_effects[id].queue_free()
	_status_effects.erase(id)
	if p_update:
		update_status_effects()


## Upgrades the tower by one tier on the specified path. Param cb is called when the upgrade finishes, and has a boolean parameter that stores whether the upgrade was successful.
func upgrade_tower(path: int, cb: Callable = Utils.null_callable) -> void:
	var tier: int = current_upgrade[path] + 1
	var upgrade: Upgrade = upgrades.get_upgrade(path, tier)

	money_requested.emit(upgrade.cost, true, func(success: bool) -> void:
		cb.call(success)

		if not success:
			return

		current_upgrade[path] = tier

		var mutable_data_scene: PackedScene = _get_current_mutable_data_scene()

		var new_mutable_data: MutableData = mutable_data_scene.instantiate()
		new_mutable_data.name = _mutable_data.name

		_mutable_data.queue_free()
		_mutable_data = new_mutable_data
		add_child.call_deferred(new_mutable_data)
		update_status_effects.call_deferred()
	)


func enemy_in_range(p_range: float) -> bool:
	_range_area.scale = Vector2.ONE * p_range
	return _range_area.has_overlapping_areas()


## Selects the tower in preview mode. Use when the tower is in placement mode.
func select_to_place() -> void:
	_range_animations.play("show_range")
	_range_animations.advance(_range_animations.current_animation_length)


## Changes the color to represent an invalid placement position. Use when the tower is in placement mode.
func set_display_invalid() -> void:
	modulate = Color(1.0, 0.1, 0.1, 0.4)


## Changes the color to represent a valid placement position. Use when the tower is in placement mode.
func set_display_valid() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.4)


func _get_tile_danger_level_multiplier(tile: Vector2i) -> float:
	var dist := tile.distance_to(tile_position)
	## Danger value computed using range and distance.
	var danger: float = stats.range - dist + 0.5
	danger = clampf(danger, 0.0, 1.0)
	if danger < 1.0 and danger > 0.0:
		danger = sqrt(danger)
	return danger


func _on_input_received(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		tower_clicked.emit()


func _run_for_tiles_in_range(cb: Callable) -> void:
	var visited: Dictionary[Vector2i, bool] = {}
	var to_visit: Array[Vector2i] = [tile_position]

	while not to_visit.is_empty():
		var top_tile: Vector2i = to_visit.back()
		to_visit.pop_back()

		if visited.has(top_tile):
			continue
		visited[top_tile] = true

		var overlap_ratio: float = _get_tile_danger_level_multiplier(top_tile)

		if (overlap_ratio == 0.0):
			continue

		var tile_ref: Tile = tile_controller.tiles.get_tile(top_tile)
		cb.call(tile_ref, overlap_ratio)

		to_visit.push_back(top_tile + Vector2i(0, 1))
		to_visit.push_back(top_tile + Vector2i(0, -1))
		to_visit.push_back(top_tile + Vector2i(1, 0))
		to_visit.push_back(top_tile + Vector2i(-1, 0))


func _get_current_mutable_data_scene() -> PackedScene:
	var mutable_data_directory: String = self.scene_file_path.get_base_dir().path_join("mutable_data")
	var mutable_data_path: String = mutable_data_directory.path_join("%s%s.tscn" % current_upgrade)
	return load(mutable_data_path)
