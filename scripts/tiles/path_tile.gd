class_name PathTile
extends Tile

var east_wall: Wall
var south_wall: Wall

var next_path: Vector2i
var distance_from_finish: int
var danger_level: float = 0.0
