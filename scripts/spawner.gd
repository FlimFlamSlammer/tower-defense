extends Node

@export var data: Array[Array] = [[{}]]
var wave: int = 0
var time_since_wave_start: float
var group_index: int

@onready var start_tile: Vector2i = get_node(Globals.TILE_CONTROLLER_PATH).start_tile

func start_wave() -> void:
	time_since_wave_start = 0.0
	group_index = 0

	
func _process(delta: float) -> void:
	time_since_wave_start += delta

	while time_since_wave_start >= data[wave][group_index].time:
		pass