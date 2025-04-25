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


func _on_collision(area: Area2D) -> void:
	if _pierce_used >= stats.pierce:
		return

	var enemy := area as Enemy
	if enemy:
		enemy.hit(stats.damage, stats.damage_type)
		_pierce_used += 1

		if "projectile_status_effects" in stats:
			var status_effects: Array[Variant] = stats.projectile_status_effects
			for effect: EnemyStatusEffect in status_effects:
				if _pierce_used == stats.pierce:
					enemy.apply_status_effect(effect)
				else:
					enemy.apply_status_effect(effect.duplicate())


	if _pierce_used == stats.pierce:
		_destruct()


func _destruct() -> void:
	queue_free()
