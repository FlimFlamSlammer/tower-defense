class_name Wall
extends Sprite2D

@export var base_stats: Dictionary[StringName, Variant]
@export var cost: int

var tile_pos: Vector2i:
	set(val):
		tile_pos = val
		position = tile_map.map_to_local(Vector2i(val.x, val.y * 2 + int(not vertical)))


var vertical: bool:
	set(val):
		vertical = val
		if vertical:
			rotation = 0.0
		else:
			rotation = TAU * 0.25

		tile_pos = tile_pos

@onready var tile_map: TileMapLayer = get_node(Globals.TILE_CONTROLLER_PATH).wall_tile_map

@onready var stats = base_stats.duplicate()


func hit(damage: float):
	stats.health -= damage
	if stats.health <= 0:
		queue_free()
