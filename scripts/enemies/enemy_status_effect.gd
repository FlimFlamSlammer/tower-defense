class_name EnemyStatusEffect
extends Node

signal expired()
signal ticked(callable: Callable)

@export var id: StringName
@export var stat_multipliers: Dictionary[StringName, float]
@export var stat_setters: Dictionary[StringName, Variant]
@export var priority: int

func _apply_tick(stats: Dictionary) -> void:
	pass


func apply(stats: Dictionary[StringName, Variant]) -> void:
	for key: StringName in stat_multipliers.keys():
		stats[key] *= stat_multipliers[key]

	for key: StringName in stat_setters.keys():
		stats[key] = stat_setters[key]


func _expire() -> void:
	expired.emit()


func _on_tick() -> void:
	ticked.emit(_apply_tick)
