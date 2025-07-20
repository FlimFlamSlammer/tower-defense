class_name RayCastProjectile
extends Projectile

@export var _ray_cast: RayCast2D
@export var _tracer: Line2D
@export var _animation_player: AnimationPlayer

var _last_normal := Vector2.ZERO
var _last_pos := Vector2.ZERO

func _ready() -> void:
	super ()

	_ray_cast.force_raycast_update()
	while _ray_cast.is_colliding() and _pierce_used < stats.pierce:
		var collider: Area2D = _ray_cast.get_collider()

		_on_collision(collider)

		_ray_cast.add_exception(collider)
		_ray_cast.force_raycast_update()

	if _last_normal == Vector2.ZERO:
		_destruct()


func _on_collision(area: Area2D) -> void:
	if _pierce_used + 1 == stats.pierce:
		_last_pos = _ray_cast.get_collision_point()
		_last_normal = _ray_cast.get_collision_normal()
	super (area)


func _destruct() -> void:
	_ray_cast.enabled = false
	if _tracer:
		if _last_normal == Vector2.ZERO:
			_tracer.add_point(Vector2.RIGHT * 8192)
		else:
			_tracer.add_point(to_local(_last_pos))

	if _animation_player:
		_animation_player.play("fire")
	else:
		queue_free()
