class_name ShootingTower
extends Tower

@onready var _attack_timer: Timer = $AttackTimer

func _process(delta: float) -> void:
	attempt_fire(_attack_timer, _fire)


func update_danger_levels(group: String) -> void:
	var visited: Dictionary = {}
	var to_visit: Array[Vector2i] = [tile_position]

	while not to_visit.is_empty():
		var top_tile: Vector2i = to_visit.back()
		to_visit.pop_back()

		if visited.has(top_tile):
			continue
		visited[top_tile] = true

		var danger_mult: float = _get_tile_danger_level_multiplier(top_tile)

		if (danger_mult == 0.0):
			continue

		var tile_ref := _tile_controller.tiles.get_tile(top_tile) as PathTile
		if tile_ref:
			tile_ref.danger_level += danger_mult * stats.damage * stats.fire_rate

		to_visit.push_back(top_tile + Vector2i(0, 1))
		to_visit.push_back(top_tile + Vector2i(0, -1))
		to_visit.push_back(top_tile + Vector2i(1, 0))
		to_visit.push_back(top_tile + Vector2i(-1, 0))


func _fire(target: Enemy) -> void:
	pass


func attempt_fire(timer: Timer, fire: Callable) -> void:
	if not _placed or not timer.is_stopped(): return

	var target: Enemy = _get_target(stats.range)
	if not target: return
	_mutable_data.get_node("Pivot").look_at(target.global_position)
	_mutable_data.animations.stop()
	_mutable_data.animations.play("fire")
	fire.call(target)
	timer.start(1.0 / stats.fire_rate)


func _get_target(p_range: float) -> Enemy:
	if not enemy_in_range(p_range):
		return null

	var best_target: Enemy
	var best_target_value: float = - INF

	var overlapping_areas: Array[Area2D] = _range_area.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy := area as Enemy
		var enemy_value: float
		match targeting:
			Targeting.FIRST:
				enemy_value = - enemy.get_distance_from_finish()
			Targeting.LAST:
				enemy_value = enemy.get_distance_from_finish()
			Targeting.STRONG:
				enemy_value = enemy.health
			Targeting.WEAK:
				enemy_value = - enemy.health
			Targeting.CLOSE:
				enemy_value = - global_position.distance_squared_to(enemy.global_position)
			Targeting.FAR:
				enemy_value = global_position.distance_squared_to(enemy.global_position)

		if enemy_value > best_target_value:
			best_target_value = enemy_value
			best_target = enemy

	return best_target
