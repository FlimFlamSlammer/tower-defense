class_name GroupSpawner
extends Timer

signal finished()
signal enemy_spawned(enemy: Enemy)

var group_data: Dictionary

var _counter: int = 0

func _ready() -> void:
	wait_time = group_data.interval
	start()


func _spawn_enemy() -> void:
	var spawner := get_parent() as Spawner
	var enemy: Enemy = group_data.type.instantiate()
	enemy.cur_tile = spawner.tile_controller.start_tile
	enemy.position = spawner.tile_controller.map_to_local(enemy.cur_tile)
	enemy_spawned.emit(enemy)
	get_parent().add_sibling(enemy)

	_counter += 1
	if _counter >= group_data.amount:
		stop()
		finished.emit()
		queue_free()
