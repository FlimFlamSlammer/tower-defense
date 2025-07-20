class_name Trail2D
extends Line2D

const EXPECTED_FRAMERATE: int = 512

@export var lifetime: float = 0.5
@export var emitting: bool = true

var _time: float = 0.0

@onready var _age_queue: Queue = Queue.new(lifetime * EXPECTED_FRAMERATE)
@onready var _parent: Node2D = get_parent()

var offset := Vector2.ZERO
func _ready() -> void:
	offset = position
	top_level = true


func _process(delta: float) -> void:
	global_position = Vector2.ZERO

	if emitting and _age_queue.push(_time):
		var point := _parent.global_position + offset.rotated(_parent.global_rotation)
		add_point(point, 0)

	while _age_queue.size() > 0 and _age_queue.front() + lifetime < _time:
		remove_point(get_point_count() - 1)
		_age_queue.pop()

	_time += delta
