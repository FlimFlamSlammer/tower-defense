class_name Projectile
extends Area2D

@export var speed: float = 100
@export var damage: float = 1
@export var pierce: int = 1

var movement_dir: float

var _movement_vector := Vector2.UP
var _pierce_used: int = 0

func _ready() -> void:
	_calculate_movement_vector()


func _process(delta: float) -> void:
	translate(_movement_vector * delta)


func _on_area_entered(area: Area2D) -> void:
	var enemy := area as Enemy
	if not enemy: return

	enemy.health -= damage

	_pierce_used += 1
	if _pierce_used >= pierce:
		queue_free()


func _calculate_movement_vector() -> void:
	_movement_vector = _movement_vector.rotated(movement_dir)
