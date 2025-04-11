class_name TowerStatusEffect
extends Node

signal expired()
signal ticked(apply_tick: Callable)

@export var id: StringName
@export var stat_multipliers: Dictionary[StringName, float]
@export var stat_setters: Dictionary[StringName, Variant]
@export var priority: int = 0
## Persistent effects need to be continuously given by the source. Most buffs from support towers are persistent.
@export var persistent: bool = true

func _apply_tick(stats: Dictionary) -> void:
	pass


func apply(stats: Dictionary) -> void:
	for key in stat_multipliers.keys():
		stats[key] *= stat_multipliers[key]

	for key in stat_setters.keys():
		stats[key] = stat_setters[key]


func _expire() -> void:
	expired.emit()


func _on_tick() -> void:
	ticked.emit(_apply_tick)
