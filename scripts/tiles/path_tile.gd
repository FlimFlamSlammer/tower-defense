class_name PathTile
extends Tile

var east_wall: Wall
var south_wall: Wall

var next_path: Dictionary[Array, Vector2i]
var alternative_next_paths: Dictionary[Array, Array]
var distance_to_finish: Dictionary[Array, int]
var danger_level_to_finish: Dictionary[Array, float]
var danger_level: float = 0.0
