class_name ColliderPivot
extends Node2D

const MAX_ROTATION_ANGLE: float = TAU / 64

func update_rotation(new_rotation: float, delta_rotation: float) -> void:
	if abs(delta_rotation) <= MAX_ROTATION_ANGLE:
		rotation = new_rotation
		return

	var steps: int = ceili(abs(delta_rotation) / MAX_ROTATION_ANGLE)
	var initial_rotation: float = rotation

	var step: int = 1
	while step <= steps:
		rotation = lerpf(initial_rotation, initial_rotation + delta_rotation, step / steps)
		step += 1

	rotation = new_rotation
