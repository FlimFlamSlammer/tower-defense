class_name Projectile
extends Area2D

@export var speed: float = 7000.0
@export var damage: float = 1.0
@export var pierce: int = 1

var movement_dir: float

var _movement_vector := Vector2.RIGHT
var _pierce_used: int = 0

func _ready() -> void:
	_calculate_movement_vector()


func _process(delta: float) -> void:
	translate(speed * _movement_vector * delta)


func _on_area_entered(area: Area2D) -> void:
	if _pierce_used >= pierce:
		return

	var enemy := area as Enemy

	enemy.hit(damage)

	_pierce_used += 1
	if _pierce_used >= pierce:
		hide()
		queue_free()


func _calculate_movement_vector() -> void:
	_movement_vector = _movement_vector.rotated(movement_dir)
