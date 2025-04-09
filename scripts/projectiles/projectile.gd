class_name Projectile
extends Node2D

var stats: Dictionary[StringName, Variant]

var movement_dir: float

var _movement_vector := Vector2.RIGHT
var _pierce_used: int = 0

func _ready() -> void:
	_calculate_movement_vector()
	rotation = movement_dir


func _process(delta: float) -> void:
	translate(stats.projectile_speed * _movement_vector * delta)


func _on_area_entered(area: Area2D) -> void:
	if _pierce_used >= stats.pierce:
		return

	var enemy := area as Enemy

	enemy.hit(stats.damage, stats.damage_type)

	_pierce_used += 1
	if _pierce_used >= stats.pierce:
		hide()
		queue_free()


func _calculate_movement_vector() -> void:
	_movement_vector = _movement_vector.rotated(movement_dir)
