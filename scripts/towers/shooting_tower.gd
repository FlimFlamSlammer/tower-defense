class_name ShootingTower
extends Tower

@export var initial_projectile: PackedScene
@export var initial_projectile_offset := Vector2.UP * 24

@onready var _pivot: Node2D = $Pivot
@onready var _attack_timer: Timer = $AttackTimer

func _ready() -> void:
	stats.projectile = initial_projectile
	stats.projectile_offset = initial_projectile_offset


func _process(delta: float) -> void:
	super(delta)
	if enemy_in_range(stats.range):
		point_and_fire(_attack_timer, _fire)


func update_danger_levels(group: String) -> void:
	var visited: Dictionary = {}
	var tiles: Array[Vector2i] = [tile_position]

	while not tiles.is_empty():
		var top_tile: Vector2i = tiles.back()
		tiles.pop_back()

		if visited.has(top_tile):
			continue
		visited[top_tile] = true

		var danger_mult: float = _get_tile_danger_level_multiplier(top_tile)

		if (danger_mult == 0.0):
			continue

		var tile_ref := _tile_controller.tiles.get_tile(top_tile) as PathTile
		if tile_ref:
			tile_ref.danger_level += danger_mult * stats.damage * stats.fire_rate

		tiles.push_back(top_tile + Vector2i(0, 1))
		tiles.push_back(top_tile + Vector2i(0, -1))
		tiles.push_back(top_tile + Vector2i(1, 0))
		tiles.push_back(top_tile + Vector2i(-1, 0))


func _fire(target: Enemy) -> void:
	pass


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
	var best_target_value: float = - INF

	var overlapping_areas: Array[Area2D] = _range_area.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy := area as Enemy
		var enemy_value: float
		match targeting:
			Targeting.FIRST:
				enemy_value = - enemy.get_distance_from_finish()
			Targeting.LAST:
				enemy_value = enemy.get_distance_from_finish()
			Targeting.STRONG:
				enemy_value = enemy.health
			Targeting.WEAK:
				enemy_value = - enemy.health
			Targeting.CLOSE:
				enemy_value = - global_position.distance_squared_to(enemy.global_position)
			Targeting.FAR:
				enemy_value = global_position.distance_squared_to(enemy.global_position)

		if enemy_value > best_target_value:
			best_target_value = enemy_value
			best_target = enemy

	return best_target
