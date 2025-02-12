class_name Enemy
extends Area2D

@export var max_health = 5
@export var health = 5
@export var speed = 1 ## Speed in tiles per second.

var cur_tile: Vector2i
var next_tile: Vector2i
var progress: float

@onready var tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)

func _process(delta: float) -> void:
	var cur_tile_position: Vector2 = tile_controller.map_to_local(cur_tile)
	var next_tile_position: Vector2 = tile_controller.map_to_local(next_tile)

	progress += speed * delta
	

func get_distance_from_finish() -> float:
	var cur_tile_ref := tile_controller.tiles.get_tile(cur_tile) as PathTile
	var next_tile_ref := tile_controller.tiles.get_tile(next_tile) as PathTile

	var cur_tile_dist: int = cur_tile_ref.distance_from_finish
	var next_tile_dist: int = next_tile_ref.distance_from_finish

	return cur_tile_dist * (1 - progress) + next_tile_dist * progress