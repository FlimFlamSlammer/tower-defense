class_name Spawner
extends Node

signal enemySpawned(enemy: Enemy)

@export var wave_data: WaveData
var wave: int = 0

var _wave_spawner: PackedScene = preload("uid://bsxu1mlbbwsws")

@onready var tile_controller := get_node(Globals.TILE_CONTROLLER_PATH) as TileController

func _ready() -> void:
	var start_wave_button: Button = get_tree().get_first_node_in_group("start_wave_button")
	start_wave_button.pressed.connect(start_wave)

func start_wave() -> void:
	wave += 1;
	var wave_spawner: WaveSpawner = _wave_spawner.instantiate()
	wave_spawner.wave_data = wave_data.data[wave - 1] # zero-indexing
	add_child(wave_spawner)
