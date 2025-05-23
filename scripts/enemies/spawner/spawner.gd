class_name Spawner
extends Node

signal enemy_spawned(enemy: Enemy)
signal wave_started()
signal wave_ended()

@export var wave_data: WaveData

var wave: int = 0 ## The current wave (zero-indexed)
var spawning: bool = false ## Whether or not this [Spawner] is currently spawning

var _wave_spawner: PackedScene = preload("res://scenes/enemies/spawner/wave_spawner.tscn")

var _remaining_wave_spawners: int = 0

@onready var tile_controller: TileController = Globals.get_tile_controller(get_tree())

func start_wave() -> void:
	wave += 1;
	var wave_spawner: WaveSpawner = _wave_spawner.instantiate()

	wave_spawner.wave_data = wave_data.data[wave - 1] # zero-indexing
	wave_spawner.enemy_spawned.connect(enemy_spawned.emit)
	wave_spawner.finished.connect(_on_wave_spawner_finished)

	_remaining_wave_spawners += 1
	spawning = true
	wave_started.emit()

	add_child(wave_spawner)


func _on_wave_spawner_finished() -> void:
	_remaining_wave_spawners -= 1
	wave_ended.emit()
	if _remaining_wave_spawners == 0:
		spawning = false
