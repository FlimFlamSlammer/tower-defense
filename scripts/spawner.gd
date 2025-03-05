extends Node

@export var data: Array[Array] = [[{}]]
var wave: int = 0
var _time_since_wave_start: float
var _group_index: int

var _subprocessor: PackedScene = preload("res://scenes/spawner_subprocessor.tscn")

@onready var start_tile: Vector2i = get_node(Globals.TILE_CONTROLLER_PATH).start_tile

func _process(delta: float) -> void:
	_time_since_wave_start += delta

	while _time_since_wave_start >= data[wave][_group_index].time:
		var subprocessor: SpawnerSubprocessor = _subprocessor.instantiate()
		subprocessor.group = data[wave][_group_index]
		add_child(subprocessor)


func start_wave() -> void:
	_time_since_wave_start = 0.0
	_group_index = 0
