class_name Queue
extends RefCounted

var _size: int
var _cur_size: int = 0
var _front: int = 0
var _rear: int = 0
var _data: Array[Variant]

func _init(p_size: int) -> void:
	_size = p_size
	_data = []
	_data.resize(p_size)


func push(item: Variant) -> bool:
	if (_rear + 1) % _size == _front:
		return false

	_data[_rear] = item
	_rear = (_rear + 1) % _size
	_cur_size += 1

	return true


func pop() -> void:
	if _front == _rear:
		return

	_front = (_front + 1) % _size
	_cur_size -= 1


func front() -> Variant:
	return _data[_front]


func is_empty() -> bool:
	return _front == _rear


func size() -> int:
	return _cur_size
