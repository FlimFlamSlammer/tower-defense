class_name Crossbow
extends ShootingTower

func _fire(target: Enemy) -> void:
	var new_projectile: Bolt = stats.projectile.instantiate()

	new_projectile.stats = stats.duplicate()
	new_projectile.movement_dir = _mutable_data.pivot.rotation

	var rotated_offset: Vector2 = stats.projectile_offset.rotated(new_projectile.movement_dir)
	new_projectile.position = position + rotated_offset

	add_sibling(new_projectile)
