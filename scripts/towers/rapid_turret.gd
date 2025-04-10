class_name RapidTurret
extends ShootingTower

var _current_barrel: int = 0

func _fire(target: Enemy) -> void:
	var new_projectile: Bullet = stats.projectile.instantiate()

	new_projectile.stats = stats.duplicate()
	new_projectile.movement_dir = _mutable_data.pivot.rotation

	var rotated_offset: Vector2 = stats.projectile_offset[_current_barrel].rotated(new_projectile.movement_dir)
	new_projectile.position = position + rotated_offset

	_current_barrel = (_current_barrel + 1) % stats.projectile_offset.size()

	add_sibling(new_projectile)


func _update_tile_danger_levels(group: StringName, current_danger_level: float, danger_mult: float) -> float:
	if group == Tower.Groups.ATTACKING:
		var diff: float = stats.fire_rate * stats.damage
		return current_danger_level + (danger_mult * diff)

	return current_danger_level
