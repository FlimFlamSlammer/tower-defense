class_name WaveSpawner
extends Node

signal finished()
signal enemy_spawned(enemy: Enemy)

var wave_data: Array

var _time_since_wave_start: float = 0.0
var _group_index: int = 0
var _groups_finished: int = 0

var _group_spawner: PackedScene = preload("uid://b616w7ivj0t6t")

@onready var _start_tile: Vector2i = (get_node(Globals.TILE_CONTROLLER_PATH) as TileController).start_tile

func _process(delta: float) -> void:
	_time_since_wave_start += delta

	
	while _group_index < wave_data.size() and _time_since_wave_start >= wave_data[_group_index].time:
		var group_spawner: GroupSpawner
		group_spawner = _group_spawner.instantiate()
		group_spawner.group_data = wave_data[_group_index]

		group_spawner.finished.connect(_on_group_spawner_finish)
		group_spawner.enemy_spawned.connect(enemy_spawned.emit)

		add_sibling(group_spawner)

		_group_index += 1;


func _on_group_spawner_finish():
	_groups_finished += 1
	if _groups_finished == wave_data.size():
		queue_free()
		finished.emit()
