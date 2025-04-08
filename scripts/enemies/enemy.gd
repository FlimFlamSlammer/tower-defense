class_name Enemy
extends Area2D

signal enemy_leaked(health: float)

@export var base_stats: Dictionary[StringName, Variant]
@export var initial_health_ratio: float = 1.0

var cur_tile := Vector2i(-1, 2)
var next_tile := Vector2i(0, 2)
var progress: float
var stats: Dictionary[StringName, Variant]

var _status_effects: Dictionary[StringName, EnemyStatusEffect]

@onready var tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)

func _ready() -> void:
	stats = base_stats.duplicate()
	stats.health = initial_health_ratio * stats.max_health


func _process(delta: float) -> void:
	progress += stats.speed * delta

	while progress >= 1:
		progress -= 1.0
		cur_tile = next_tile
		if cur_tile == tile_controller.finish_tile:
			enemy_leaked.emit(stats.health)
			queue_free()
			return
		next_tile = (tile_controller.tiles.get_tile(next_tile) as PathTile).next_path
		_rotate()

	var cur_tile_position: Vector2 = tile_controller.map_to_local(cur_tile)
	var next_tile_position: Vector2 = tile_controller.map_to_local(next_tile)
	position = lerp(cur_tile_position, next_tile_position, progress)


func hit(damage: float, type: Globals.DamageTypes) -> bool:
	if type in stats.immunities:
		return false

	stats.health -= damage
	if stats.health <= 0.0:
		hide()
		queue_free()

	return true


func apply_status_effect(effect: EnemyStatusEffect, update: bool = true):
	if _status_effects.has(effect.id):
		if _status_effects[effect.id].priority > effect.priority:
			effect.queue_free()
			return
		else:
			remove_status_effect(effect.id, false)

	effect.expired.connect(remove_status_effect.bind(effect.id))

	_status_effects[effect.id] = effect
	effect.reparent(self)

	if update:
		_update_status_effects()


func remove_status_effect(id: StringName, update: bool = true):
	_status_effects[id].queue_free()
	_status_effects.erase(id)
	if update:
		_update_status_effects()


func get_distance_from_finish() -> float:
	var cur_tile_ref := tile_controller.tiles.get_tile(cur_tile) as PathTile
	var next_tile_ref := tile_controller.tiles.get_tile(next_tile) as PathTile

	var cur_tile_dist: int = cur_tile_ref.distance_from_finish
	var next_tile_dist: int = next_tile_ref.distance_from_finish

	return cur_tile_dist * (1 - progress) + next_tile_dist * progress


func _rotate() -> void:
	var new_rotation: float = lerp_angle(rotation, Vector2(cur_tile).angle_to_point(next_tile), 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", new_rotation, 0.15 / stats.speed * absf(new_rotation - rotation))


func _update_status_effects():
	stats = base_stats.duplicate()
	for id in _status_effects.keys():
		_status_effects[id].apply(stats)
