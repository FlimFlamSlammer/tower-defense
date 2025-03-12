class_name WaveSpawner
extends Node

var wave_data: Array

var _time_since_wave_start: float = 0.0
var _group_index: int = 0

var _group_spawner: PackedScene = preload("uid://b616w7ivj0t6t")

@onready var start_tile: Vector2i = (get_node(Globals.TILE_CONTROLLER_PATH) as TileController).start_tile

func _process(delta: float) -> void:
	_time_since_wave_start += delta

	while _group_index < wave_data.size() and _time_since_wave_start >= wave_data[_group_index].time:
		var group_spawner: GroupSpawner = _group_spawner.instantiate()
		group_spawner.group = wave_data[_group_index]
		add_sibling(group_spawner)

		_group_index += 1;

	if _group_index == wave_data.size():
		queue_free()
