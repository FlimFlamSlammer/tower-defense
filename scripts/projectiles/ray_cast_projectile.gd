class_name RayCastProjectile
extends Projectile

@export var _ray_cast: RayCast2D

func _ready() -> void:
	super ()
	while _ray_cast.is_colliding() and _pierce_used <= stats.pierce:
		var enemy := _ray_cast.get_collider() as Enemy
		if enemy:
			enemy.hit(stats.damage, stats.damage_type)

			_ray_cast.add_exception(enemy)
			_ray_cast.force_raycast_update()
			_pierce_used += 1