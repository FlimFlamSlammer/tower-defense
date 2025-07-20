class_name ColliderPivot
extends Node2D

const MAX_ROTATION_ANGLE: float = TAU / 64

func update_rotation(new_rotation: float, clockwise: bool) -> void:
	var delta_angle: float = fposmod(new_rotation - rotation, 360)
	if not clockwise:
		delta_angle = 360 - delta_angle

	if delta_angle <= MAX_ROTATION_ANGLE:
		rotation = new_rotation
		return

	var steps: int = ceili(delta_angle / MAX_ROTATION_ANGLE)
	var initial_rotation: float = rotation

	var step: int = 1
	while step <= steps:
		rotation = lerp(initial_rotation, new_rotation, step/steps)
		step += 1
