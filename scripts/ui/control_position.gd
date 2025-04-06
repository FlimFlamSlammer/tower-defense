class_name ControlPosition
extends RefCounted

var _top: float
var _bottom: float
var _left: float
var _right: float

var position: Vector2: ## Stores the position of the top-left corner of this ControlPosition relative to the anchor point.
	get:
		return Vector2(_left, _top)
	set(val):
		var length: float = _right - _left
		_right = val.x + length
		_left = val.x

		length = _bottom - _top
		_bottom = val.y + length
		_top = val.y

var position_inverted: Vector2: ## Stores the position of the bottom-right corner of this ControlPosition relative to the anchor point.
	get:
		return Vector2(_right, _bottom)
	set(val):
		var length: float = _left - _right
		_left = val.x + length
		_right = val.x

		length = _top - _bottom
		_top = val.y + length
		_bottom = val.y

func _init(node: Control) -> void:
	update_position(node)

func set_node_position(node: Control) -> void:
	node.offset_top = _top
	node.offset_bottom = _bottom
	node.offset_left = _left
	node.offset_right = _right

func tween_node_position(node: Control, duration: float, ease_type: int, trans_type: int) -> void:
	Globals.tween_properties(node, ["offset_top", "offset_bottom", "offset_left", "offset_right"], [_top, _bottom, _left, _right], duration, ease_type, trans_type)

func update_position(node: Control) -> void:
	_top = node.offset_top
	_bottom = node.offset_bottom
	_left = node.offset_left
	_right = node.offset_right