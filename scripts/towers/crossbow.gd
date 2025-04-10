class_name Crossbow
extends ShootingTower

const EXPECTED_EXPLOSION_PIERCE: int = 3

func _fire(target: Enemy) -> void:
	var new_projectile: Bolt = stats.projectile.instantiate()

	new_projectile.stats = stats.duplicate()
	new_projectile.movement_dir = _mutable_data.pivot.rotation

	var rotated_offset: Vector2 = stats.projectile_offset.rotated(new_projectile.movement_dir)
	new_projectile.position = position + rotated_offset

	add_sibling(new_projectile)

func _update_tile_danger_levels(group: StringName, current_danger_level: float, danger_mult: float) -> float:
	if group == Globals.TowerGroups.ATTACKING:
		var diff: float = stats.fire_rate * stats.damage
		if "explosion_damage" in stats:
			diff += stats.explosion_damage * EXPECTED_EXPLOSION_PIERCE
		return current_danger_level + (danger_mult * diff)

	return current_danger_level
