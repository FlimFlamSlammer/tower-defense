class_name GroupSpawner
extends Timer

var group: Dictionary

var _counter: int = 0

func _ready() -> void:
	wait_time = group.interval
	start()


func _spawn_enemy() -> void:
	var spawner := get_parent() as Spawner
	var enemy: Enemy = group.type.instantiate()
	enemy.cur_tile = spawner.tile_controller.start_tile
	enemy.position = spawner.tile_controller.map_to_local(enemy.cur_tile)
	get_parent().add_sibling(enemy)
	get_parent().enemySpawned.emit(enemy)

	_counter += 1
	if _counter >= group.amount:
		stop()
		queue_free()
