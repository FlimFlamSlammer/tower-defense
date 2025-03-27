class_name Crossbow
extends ShootingTower

func _fire(target: Enemy) -> void:
	var new_projectile := stats.projectile.instantiate() as Bolt

	new_projectile.position = position
	new_projectile.movement_dir = _pivot.rotation
	new_projectile.rotation = _pivot.rotation
	new_projectile.pierce = stats.pierce
	new_projectile.damage = stats.damage

	var rotated_offset: Vector2 = stats.projectile_offset.rotated(new_projectile.movement_dir)
	new_projectile.translate(rotated_offset)

	add_sibling(new_projectile)
