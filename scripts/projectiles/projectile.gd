class_name Projectile
extends Node2D

var stats: Dictionary[StringName, Variant]

var movement_dir: float

var _pierce_used: int = 0

func _ready() -> void:
	rotation = movement_dir

	if "projectile_status_effects" in stats:
		var status_effects: Array[Variant] = stats.projectile_status_effects.duplicate()
		for i in range(status_effects.size()):
			status_effects[i] = status_effects[i].duplicate()
			add_child(status_effects[i])

		stats.projectile_status_effects = status_effects
