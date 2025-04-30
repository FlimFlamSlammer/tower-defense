class_name Breaker
extends Enemy

@onready var _blast_area: Area2D = $BlastArea
@onready var _explosion_effects: GPUParticles2D = $Fire

# Checks if there is a wall between cur_tile and next_tile. Damages the enemy and wall if it exists.
func _check_wall() -> void:
	var wall: Wall = tile_controller.get_wall_between(cur_tile, next_tile)

	if wall:
		_explode()


func _explode() -> void:
	var walls: Array[Area2D] = _blast_area.get_overlapping_areas()
	for wall: Wall in walls:
		wall.hit(stats.damage)

	_explosion_effects.reparent(get_parent())
	_explosion_effects.emitting = true

	queue_free()
