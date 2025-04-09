class_name MutableData
extends Node2D

@export var stats: Dictionary[StringName, Variant]

@onready var animations: AnimationPlayer = get_node_or_null("Animations")
@onready var pivot: Node2D = get_node_or_null("Pivot")
