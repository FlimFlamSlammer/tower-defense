class_name SniperTurret
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
