class_name PriorityQueue
extends RefCounted

var _comparator: Callable = func less(a, b) -> bool:
	return a < b
var _pq: Array = []

func _init(comparator: Callable = _comparator) -> void:
	if comparator:
		_comparator = comparator


func size():
	return _pq.size()


func top():
	return _pq[0] if _pq.size() else null


func push(value) -> void:
	_pq.push_back(value)
	
	var index: int = _pq.size() - 1
	var parent_index: int = (index - 1) / 2

	while (index > 0 and not _comparator.call(_pq[index], _pq[parent_index])):
		var temp = _pq[parent_index]
		_pq[parent_index] = _pq[index]
		_pq[index] = temp
		
		index = parent_index
		parent_index = (index - 1) / 2


func pop() -> void:
	_pq[0] = _pq.back()
	_pq.pop_back()

	var parent_index: int = 0
	while true:
		var left_index: int = 2 * parent_index + 1
		var right_index: int = 2 * parent_index + 2
		var greatest: int = parent_index

		if left_index < _pq.size() and not _comparator.call(_pq[left_index], _pq[greatest]):
			greatest = left_index

		if right_index < _pq.size() and not _comparator.call(_pq[right_index], _pq[greatest]):
			greatest = right_index

		if parent_index == greatest:
			break

		var temp = _pq[parent_index]
		_pq[parent_index] = _pq[greatest]
		_pq[greatest] = temp

		parent_index = greatest