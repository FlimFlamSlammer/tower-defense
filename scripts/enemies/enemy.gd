class_name Enemy
extends Area2D

signal enemyLeaked(health: float)

@export var max_health = 5
@export var health = 5
@export var speed: float = 0.3 ## Speed in tiles per second.

var cur_tile := Vector2i(-1, 2)
var next_tile := Vector2i(0, 2)
var progress: float

@onready var tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)

func _process(delta: float) -> void:
	progress += speed * delta

	while progress >= 1:
		progress -= 1.0
		cur_tile = next_tile
		if cur_tile == tile_controller.finish_tile:
			enemyLeaked.emit(health)
			queue_free()
			return
		next_tile = (tile_controller.tiles.get_tile(next_tile) as PathTile).next_path
		_rotate()

	var cur_tile_position: Vector2 = tile_controller.map_to_local(cur_tile)
	var next_tile_position: Vector2 = tile_controller.map_to_local(next_tile)
	position = lerp(cur_tile_position, next_tile_position, progress)


func hit(damage: float):
	health -= damage
	if health <= 0.0:
		hide()
		queue_free()

func get_distance_from_finish() -> float:
	var cur_tile_ref := tile_controller.tiles.get_tile(cur_tile) as PathTile
	var next_tile_ref := tile_controller.tiles.get_tile(next_tile) as PathTile

	var cur_tile_dist: int = cur_tile_ref.distance_from_finish
	var next_tile_dist: int = next_tile_ref.distance_from_finish

	return cur_tile_dist * (1 - progress) + next_tile_dist * progress


func _rotate() -> void:
	var new_rotation: float = lerp_angle(rotation, Vector2(cur_tile).angle_to_point(next_tile), 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", new_rotation, 0.15 / speed * absf(new_rotation - rotation))
