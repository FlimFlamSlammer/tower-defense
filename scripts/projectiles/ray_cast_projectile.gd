class_name RayCastProjectile
extends Projectile

@export var _ray_cast: RayCast2D
@export var _tracer: Line2D
@export var _animation_player: AnimationPlayer

func _ready() -> void:
	super ()
	_ray_cast.force_raycast_update()
	var last_pos := Vector2.RIGHT.rotated(rotation) * 4600 # defaults to approximate screen diagonal length
	var last_normal := Vector2.ZERO
	while _ray_cast.is_colliding() and _pierce_used < stats.pierce:
		var collider: Area2D = _ray_cast.get_collider()
		var enemy := collider as Enemy
		if enemy:
			enemy.hit(stats.damage, stats.damage_type)
			_pierce_used += 1

			if "projectile_status_effects" in stats:
				var status_effects: Array[Variant] = stats.projectile_status_effects
				for effect in status_effects:
					var new_effect: EnemyStatusEffect
					if _pierce_used == stats.pierce:
						new_effect = effect
					else:
						new_effect = effect.duplicate()
					enemy.apply_status_effect(new_effect)

			last_pos = _ray_cast.get_collision_point()
			last_normal = _ray_cast.get_collision_normal()

		_ray_cast.add_exception(collider)
		_ray_cast.force_raycast_update()

	_ray_cast.enabled = false

	if _tracer:
		_tracer.add_point(to_local(last_pos))

	if _animation_player:
		_animation_player.play("fire")
	else:
		queue_free()
