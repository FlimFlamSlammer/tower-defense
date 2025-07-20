class_name PulsingBolt
extends Bolt

const FIRED_Z_INDEX: int = 1

@export var _pulse_amount: int = 3

var _attached_enemy: Enemy = null
var _attached_local_position: Vector2
var _attached_local_rotation: float

var _pulses_used: int = 0

@onready var _fire_effect: GPUParticles2D = $Fire
@onready var _blast_area: Area2D = $BlastArea
@onready var _pulse_fire_effect: GPUParticles2D = $PulseFire
@onready var _pulse_blast_area: Area2D = $PulseBlastArea
@onready var _pulse_timer: Timer = $PulseTimer

@onready var _pulse_sound: AudioStreamPlayer2D = $PulseSound
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
	enemy.tree_exited.connect(_explode_last)

	_pulse_timer.start()


func _destruct() -> void:
	pass


func _explode(area: Area2D, effect: GPUParticles2D, damage: float) -> GPUParticles2D:
	var enemies: Array[Area2D] = area.get_overlapping_areas()

	for enemy: Enemy in enemies:
		enemy.hit(damage, Globals.DamageTypes.EXPLOSION)

	var backup_effect: GPUParticles2D = effect.duplicate()

	effect.emitting = true
	effect.reparent(get_parent())
	effect.get_node("ExpirationTimer").start()

	add_child.call_deferred(backup_effect)
	return backup_effect


func _explode_last() -> void:
	if is_queued_for_deletion(): return
	_explode(_blast_area, _fire_effect, stats.explosion_damage)
	queue_free()


func _pulse() -> void:
	if _pulses_used >= _pulse_amount:
		_explode_last()
		_explosion_sound.reparent(get_parent())
		_explosion_sound.play()
		_explosion_sound.finished.connect(_explosion_sound.queue_free)
		return

	_pulse_fire_effect = _explode(_pulse_blast_area, _pulse_fire_effect, stats.pulse_damage)
	_pulse_sound.play()
	_pulses_used += 1


func _set_z_index() -> void:
	z_index = FIRED_Z_INDEX
