class_name AreaProjectile
extends Projectile

var _movement_vector := Vector2.RIGHT

func _ready() -> void:
	super ()
	_calculate_movement_vector()


func _process(delta: float) -> void:
	translate(stats.projectile_speed * _movement_vector * delta)


func _calculate_movement_vector() -> void:
	_movement_vector = _movement_vector.rotated(movement_dir)
