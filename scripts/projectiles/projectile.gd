class_name Projectile
extends Node2D

const MIN_PIERCE_DAMAGE_MULTIPLIER = 0.25

var stats: Dictionary[StringName, Variant]

var movement_dir: float

var _pierce_used: int = 0
var _exceptions: Dictionary[Enemy, bool]

func _ready() -> void:
	rotation = movement_dir

	if "attack_status_effects" in stats:
		var status_effects: Array[Variant] = stats.attack_status_effects.duplicate()
		for i in range(status_effects.size()):
			status_effects[i] = status_effects[i].duplicate()
			add_child(status_effects[i])

		stats.attack_status_effects = status_effects


func add_exception(enemy: Enemy) -> void:
	_exceptions[enemy] = true
	enemy.tree_exited.connect(remove_exception.bind(enemy))


func remove_exception(enemy: Enemy) -> void:
	_exceptions.erase(enemy)
	enemy.tree_exited.disconnect(remove_exception.bind(enemy))


func has_exception(enemy: Enemy) -> bool:
	return enemy in _exceptions


func _on_collision(area: Area2D) -> void:
	if _pierce_used >= stats.pierce:
		return

	var enemy := area as Enemy
	if not enemy or has_exception(enemy): return

	var pierce_damage_multiplier: float = 1.0 - ((1.0 - MIN_PIERCE_DAMAGE_MULTIPLIER) * _pierce_used / stats.pierce)

	enemy.hit(stats.damage * pierce_damage_multiplier, stats.damage_type, stats.armor_piercing if "armor_piercing" in stats else 0.0)
	_pierce_used += 1

	if "attack_status_effects" in stats:
		var status_effects: Array[Variant] = stats.attack_status_effects
		for effect: EnemyStatusEffect in status_effects:
			if _pierce_used == stats.pierce:
				enemy.apply_status_effect(effect)
			else:
				enemy.apply_status_effect(effect.duplicate())


	if _pierce_used == stats.pierce:
		_destruct()


func _destruct() -> void:
	queue_free()
