class_name Spawner
extends Node

signal enemy_spawned(enemy: Enemy)

@export var wave_data: WaveData
var wave: int = 0

var _wave_spawner: PackedScene = preload("uid://bsxu1mlbbwsws")

@onready var tile_controller := get_node(Globals.TILE_CONTROLLER_PATH) as TileController


func start_wave() -> void:
	wave += 1;
	var wave_spawner: WaveSpawner = _wave_spawner.instantiate()
	wave_spawner.wave_data = wave_data.data[wave - 1] # zero-indexing
	add_child(wave_spawner)
