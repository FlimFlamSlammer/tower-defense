class_name BouncingBullet
extends Bullet

@onready var _bounce_shape_cast: ShapeCast2D = $BounceShapeCast

func _on_collision(area: Area2D) -> void:
	super (area)

	_bounce_shape_cast.add_exception(area)

	var min_dist: float = 2e64
	var target: Enemy

	_ray_cast.global_position = _ray_cast.get_collision_point()
	_tracer.add_point(_ray_cast.position)
	_bounce_shape_cast.position = _ray_cast.position
	_bounce_shape_cast.force_shapecast_update()

	for i in range(_bounce_shape_cast.get_collision_count()):
		var enemy: Enemy = _bounce_shape_cast.get_collider(i)

		var dist: float = _ray_cast.global_position.distance_squared_to(enemy.position)
		if dist < min_dist:
			min_dist = dist
			target = enemy

	if target:
		movement_dir = _ray_cast.global_position.angle_to_point(target.position)
	else:
		print("FUCK")
		print(_bounce_shape_cast.get_collision_count())
		movement_dir = randf_range(-PI, PI)

	_ray_cast.global_rotation = movement_dir
