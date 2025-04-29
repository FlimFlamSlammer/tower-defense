class_name Projectile
extends Node2D

const MIN_PIERCE_DAMAGE_MULTIPLIER = 0.25

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
		var pierce_damage_multiplier: float = 1.0 - ((1.0 - MIN_PIERCE_DAMAGE_MULTIPLIER) * _pierce_used / stats.pierce)
		var armor_piercing_damage_multiplier: float = 1.0

		if "armor_piercing" in stats:
			armor_piercing_damage_multiplier = 1.0 - stats.armor_piercing
			enemy.hit(stats.damage * pierce_damage_multiplier * stats.armor_piercing, Globals.DamageTypes.NORMAL)

		enemy.hit(stats.damage * pierce_damage_multiplier * armor_piercing_damage_multiplier, stats.damage_type)
		print(stats.damage * pierce_damage_multiplier * armor_piercing_damage_multiplier)
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
