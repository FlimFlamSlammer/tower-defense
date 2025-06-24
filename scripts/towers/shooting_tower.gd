class_name ShootingTower
extends Tower

@onready var _attack_timer: Timer = $AttackTimer

func _process(_delta: float) -> void:
	if not _placed: return
	attempt_fire(_attack_timer, _fire, stats.attack_cost)


func _update_tile_danger_levels(group: StringName, current_danger_level: float, danger_mult: float, immunities: Array[Globals.DamageTypes]) -> float:
	if Groups.USES_BULLET in get_groups() and not "bullets" in status_effects:
		return current_danger_level

	if group == Tower.Groups.ATTACKING and not stats.damage_type in immunities:
		var diff: float = stats.fire_rate * stats.damage
		return current_danger_level + (danger_mult * diff)

	return current_danger_level


func _fire(target: Enemy) -> void:
	pass


func attempt_fire(timer: Timer, fire: Callable, attack_cost: int) -> void:
	if not _placed or not timer.is_stopped(): return
	if Groups.USES_BULLET in get_groups() and not "bullets" in status_effects: return

	var target: Enemy = _get_target(stats.range)
	if not target: return

	money_requested.emit(attack_cost, true, func(success: bool) -> void:
		if not success: return

		_mutable_data.pivot.look_at(target.global_position)

		if _mutable_data.animations.has_animation("fire"):
			_mutable_data.animations.stop()
			_mutable_data.animations.play("fire")

		fire.call(target)
		timer.start(1.0 / stats.fire_rate)
	)


func _get_target(p_range: float) -> Enemy:
	if not enemy_in_range(p_range):
		return null

	var best_target: Enemy
	var best_target_value: float = - INF

	var overlapping_areas: Array[Area2D] = _range_area.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy := area as Enemy
		if enemy.is_queued_for_deletion(): return
		var enemy_value: float
		match targeting:
			Targeting.FIRST:
				enemy_value = - enemy.get_distance_from_finish()
			Targeting.LAST:
				enemy_value = enemy.get_distance_from_finish()
			Targeting.STRONG:
				enemy_value = enemy.stats.health
			Targeting.WEAK:
				enemy_value = - enemy.stats.health
			Targeting.CLOSE:
				enemy_value = - global_position.distance_squared_to(enemy.global_position)
			Targeting.FAR:
				enemy_value = global_position.distance_squared_to(enemy.global_position)

		if enemy_value > best_target_value:
			best_target_value = enemy_value
			best_target = enemy

	return best_target
