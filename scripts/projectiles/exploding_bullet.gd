class_name ExplodingBullet
extends Bullet

@onready var _fire_effect: GPUParticles2D = $Fire
@onready var _blast_shape_cast: ShapeCast2D = $BlastShapeCast

@onready var _explosion_sound: AudioStreamPlayer2D = $ExplosionSound

func _on_collision(area: Area2D) -> void:
	super (area)

	if _pierce_used == stats.pierce:
		get_tree().create_timer(0.1).timeout.connect(_explode)


func _explode() -> void:
	_blast_shape_cast.position = to_local(_last_pos)
	_blast_shape_cast.force_shapecast_update()

	for i in range(_blast_shape_cast.get_collision_count()):
		var enemy: Enemy = _blast_shape_cast.get_collider(i)
		enemy.hit(stats.explosion_damage, Globals.DamageTypes.EXPLOSION)

	_fire_effect.position = to_local(_last_pos)
	_fire_effect.emitting = true
	_fire_effect.reparent(get_parent())
	_fire_effect.get_node("ExpirationTimer").start()

	_explosion_sound.position = to_local(_last_pos)
	_explosion_sound.reparent(get_parent())
	_explosion_sound.finished.connect(_explosion_sound.queue_free)
	_explosion_sound.play()
