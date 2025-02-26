class_name SpawnerSubprocessor
extends Timer

var group: Dictionary
var counter: int = 0

func _ready() -> void:
	wait_time = group.interval
	
func _spawn_enemy() -> void:
	var enemy: Enemy = group.type.instantiate()
	enemy.cur_tile = get_parent().start_tile
	get_parent().add_sibling(enemy)

	counter += 1
	if counter >= group.amount:
		stop()
		queue_free()