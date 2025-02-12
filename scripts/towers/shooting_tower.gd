class_name ShootingTower
extends Tower

@export var initial_projectile: PackedScene
@export var initial_projectile_offset := Vector2.UP * 24

@onready var _pivot: Node2D = $Pivot
@onready var _attack_timer: Timer = $AttackTimer

func _fire(target: Enemy) -> void:
	pass


func _ready() -> void:
	stats.projectile = initial_projectile
	stats.projectile_offset = initial_projectile_offset


func _process(_delta: float) -> void:
	if enemy_in_range(stats.range):
		point_and_fire(_attack_timer, _fire)


func point_and_fire(timer: Timer, fire: Callable) -> void:
	if not timer.is_stopped(): return

	var target: Enemy = _get_target(stats.range)
	_pivot.look_at(target.position)
	_custom_animations.play("fire")
	fire.call(target)
	timer.start(1.0 / stats.fire_rate)


func _get_target(p_range: float) -> Enemy:
	if not enemy_in_range(p_range):
		return null
	
	var best_target: Enemy
	var best_target_value: float = -INF

	var overlapping_areas: Array[Area2D] = _range_area.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy := area as Enemy
		var enemy_value: float
		match targeting:
			Targeting.FIRST:
				enemy_value = -enemy.get_distance_from_finish()
			Targeting.LAST:
				enemy_value = enemy.get_distance_from_finish()
			Targeting.STRONG:
				enemy_value = enemy.health
			Targeting.WEAK:
				enemy_value = -enemy.health
			Targeting.CLOSE:
				enemy_value = -global_position.distance_squared_to(enemy.global_position)
			Targeting.FAR:
				enemy_value = global_position.distance_squared_to(enemy.global_position)

		if enemy_value > best_target_value:
			best_target_value = enemy_value
			best_target = enemy

	return best_target