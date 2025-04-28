class_name Enemy
extends Area2D

const WALL_CHECK_PROGRESS_MIN = 0.2
const WALL_CHECK_PROGRESS_MAX = 0.7
const DEVIATION_CHANCE = 0.3 ## Chance to use an alternative next path instead of the main path.
const MIN_TILES_FROM_LAST_DEVIATION = 1 ## Minimum tiles moved from last deviation before able to deviate again.

signal leaked(health: float)
signal path_data_requested(immunities: Array[Globals.DamageTypes], cb: Callable)
signal died()

@export var base_stats: Dictionary[StringName, Variant]
@export var initial_health_ratio: float = 1.0

var cur_tile: Vector2i
var next_tile: Vector2i
var progress: float
var stats: Dictionary[StringName, Variant]
var tile_controller: TileController

var _status_effects: Dictionary[StringName, EnemyStatusEffect]
var _tiles_from_last_deviation: int = 4096

func _ready() -> void:
	base_stats.resistance = 1.0
	stats = base_stats.duplicate()
	stats.health = initial_health_ratio * stats.max_health

	cur_tile = tile_controller.start_tile
	path_data_requested.emit(stats.immunities, cur_tile, func(tile: PathTile) -> void:
		var next_paths: Array[Vector2i] = tile.next_paths[stats.immunities as Array[Globals.DamageTypes]]
		next_tile = next_paths[randi() % next_paths.size()]
		rotation = Vector2(cur_tile).angle_to_point(next_tile)
	)


func _process(delta: float) -> void:
	progress += stats.speed * delta

	if progress > WALL_CHECK_PROGRESS_MIN and progress < WALL_CHECK_PROGRESS_MAX:
		_check_wall()

	while progress >= 1.0:
		progress -= 1.0

		if next_tile == tile_controller.finish_tile and not is_queued_for_deletion():
				queue_free()
				died.emit()
				leaked.emit(stats.health)
				return

		path_data_requested.emit(stats.immunities, next_tile, func(tile: PathTile) -> void:
			_advance_path(tile)
			if progress > WALL_CHECK_PROGRESS_MIN:
				_check_wall()

			_rotate()
		)

	var cur_tile_local_position: Vector2 = tile_controller.tile_map.map_to_local(cur_tile)
	var next_tile_local_position: Vector2 = tile_controller.tile_map.map_to_local(next_tile)
	position = lerp(cur_tile_local_position, next_tile_local_position, progress)


func hit(damage: float, type: Globals.DamageTypes) -> bool:
	if type in stats.immunities:
		return false

	stats.health -= damage / stats.resistance
	if stats.health <= 0.0:
		hide()
		queue_free()
		died.emit()

	return true


func apply_status_effect(effect: EnemyStatusEffect, update: bool = true) -> void:
	if effect.id in _status_effects:
		if _status_effects[effect.id].priority > effect.priority:
			effect.queue_free()
			return
		else:
			remove_status_effect(effect.id, false)

	effect.expired.connect(remove_status_effect.bind(effect.id))
	var expiration_timer: Timer = effect.get_node_or_null("ExpirationTimer")
	if expiration_timer:
		expiration_timer.start()

	_status_effects[effect.id] = effect

	if effect.get_parent():
		effect.reparent(self)
	else:
		add_child(effect)

	if update:
		_update_status_effects()


func remove_status_effect(id: StringName, update: bool = true) -> void:
	_status_effects[id].queue_free()
	_status_effects.erase(id)
	if update:
		_update_status_effects()


func get_distance_from_finish() -> float:
	var cur_tile_ref := tile_controller.tiles.get_tile(cur_tile) as PathTile
	var next_tile_ref := tile_controller.tiles.get_tile(next_tile) as PathTile

	var cur_tile_dist: int = cur_tile_ref.distance_to_finish[stats.immunities as Array[Globals.DamageTypes]]
	var next_tile_dist: int = next_tile_ref.distance_to_finish[stats.immunities as Array[Globals.DamageTypes]]

	return cur_tile_dist * (1 - progress) + next_tile_dist * progress


func _advance_path(tile: PathTile) -> void:
	var previous_tile: Vector2i = cur_tile
	cur_tile = next_tile

	var next_paths: Array[Vector2i] = tile.next_paths[stats.immunities as Array[Globals.DamageTypes]]
	var alternative_paths: Array[Vector2i] = tile.alternative_next_paths[stats.immunities as Array[Globals.DamageTypes]]

	var does_next_path_go_back: bool = next_paths.size() == 1 and next_paths[0] == previous_tile
	var does_alternative_path_go_back: bool = alternative_paths.size() == 1 and alternative_paths[0] == previous_tile

	if not alternative_paths.is_empty() \
			and next_paths.size() == 1 \
			and not does_alternative_path_go_back \
			and (randf() < DEVIATION_CHANCE or does_next_path_go_back) \
			and _tiles_from_last_deviation >= MIN_TILES_FROM_LAST_DEVIATION:
		_tiles_from_last_deviation = 0
		var idx: int = randi() % alternative_paths.size()
		next_tile = alternative_paths[idx]
		if next_tile == previous_tile and alternative_paths.size() > 1:
			#idx += randi() % alternative_paths.size() - 1
			idx += 1
			idx %= alternative_paths.size()
			next_tile = alternative_paths[idx]
	else:
		var idx: int = randi() % next_paths.size()
		next_tile = next_paths[idx]
		if next_tile == previous_tile and next_paths.size() > 1:
			idx += randi() % next_paths.size() - 1
			idx %= next_paths.size()
			next_tile = next_paths[idx]


func _rotate() -> void:
	var new_rotation: float = Vector2(cur_tile).angle_to_point(next_tile)
	create_tween().tween_property(self, "rotation", new_rotation, 0.15 / stats.speed * absf(new_rotation - rotation))


func _update_status_effects() -> void:
	var prev_health: float = stats.health
	stats = base_stats.duplicate()
	stats.health = prev_health

	for id: StringName in _status_effects.keys():
		_status_effects[id].apply(stats)


# Checks if there is a wall between cur_tile and next_tile. Damages the enemy and wall if it exists.
func _check_wall() -> void:
	var wall: Wall = tile_controller.get_wall_between(cur_tile, next_tile)

	if wall:
		var damage: float = minf(wall.stats.health, stats.health)

		hit(damage, Globals.DamageTypes.WALL)
		wall.hit(damage)
