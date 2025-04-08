class_name Crossbow
extends ShootingTower

func _fire(target: Enemy) -> void:
	tower_used_money.emit(stats.attack_cost)
	
	var new_projectile: Bolt = stats.projectile.instantiate()
	var pivot: Node2D = _mutable_data.get_node("Pivot")

	new_projectile.position = position
	new_projectile.movement_dir = pivot.rotation
	new_projectile.rotation = pivot.rotation
	new_projectile.pierce = stats.pierce
	new_projectile.damage = stats.damage
	new_projectile.speed = stats.projectile_speed

	var fuse_bolt := new_projectile as FuseBolt
	if fuse_bolt:
		fuse_bolt.explosion_damage = stats.explosion_damage

	var rotated_offset: Vector2 = stats.projectile_offset.rotated(new_projectile.movement_dir)
	new_projectile.translate(rotated_offset)

	add_sibling(new_projectile)
