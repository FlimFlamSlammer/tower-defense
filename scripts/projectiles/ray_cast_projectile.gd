class_name RayCastProjectile
extends Projectile

@export var _ray_cast: RayCast2D
@export var _tracer: Line2D
@export var _animation_player: AnimationPlayer

func _ready() -> void:
	super ()
	_ray_cast.force_raycast_update()
	var last_pos: Vector2 = Vector2.RIGHT.rotated(rotation) * 8192
	var last_normal: Vector2 = Vector2.ZERO
	while _ray_cast.is_colliding() and _pierce_used < stats.pierce:
		var collider: Area2D = _ray_cast.get_collider()
		var enemy := collider as Enemy
		if enemy:
			enemy.hit(stats.damage, 1)
			_pierce_used += 1
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
