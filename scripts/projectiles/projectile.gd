class_name Projectile
extends Node2D

var stats: Dictionary[StringName, Variant]

var movement_dir: float

var _pierce_used: int = 0

func _ready() -> void:
	rotation = movement_dir
