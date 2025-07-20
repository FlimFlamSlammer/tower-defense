class_name FuseBolt
extends Bolt

const FIRED_Z_INDEX = 1

var _attached_enemy: Enemy = null
var _attached_local_position: Vector2
var _attached_local_rotation: float

@onready var _fire_effect: GPUParticles2D = $Fire
@onready var _blast_area: Area2D = $BlastArea
@onready var _fuse: Timer = $Fuse
@onready var _explosion_sound: AudioStreamPlayer2D = $ExplosionSound

func _process(delta: float) -> void:
	if _attached_enemy:
		position = _attached_enemy.to_global(_attached_local_position)
		rotation = _attached_local_rotation + _attached_enemy.rotation
	else:
		super (delta)


func _on_collision(area: Area2D) -> void:
	if _attached_enemy: return
	super (area)

	var enemy: Enemy = area

	_attached_enemy = enemy
	_attached_local_position = enemy.to_local(position)
	_attached_local_rotation = rotation - enemy.rotation
	enemy.tree_exited.connect(_explode)

	_fuse.start()


func _destruct() -> void:
	pass


func _explode() -> void:
	if is_queued_for_deletion(): return

	var enemies: Array[Area2D] = _blast_area.get_overlapping_areas()

	for enemy: Enemy in enemies:
		enemy.hit(stats.explosion_damage, Globals.DamageTypes.EXPLOSION)

	_fire_effect.emitting = true
	_fire_effect.reparent(get_parent())
	_fire_effect.get_node("ExpirationTimer").start()

	_explosion_sound.reparent(get_parent())
	_explosion_sound.play()
	_explosion_sound.finished.connect(_explosion_sound.queue_free)

	queue_free()


func _set_z_index() -> void:
	z_index = FIRED_Z_INDEX
