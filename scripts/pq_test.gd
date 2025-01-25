extends Node

var pq: PriorityQueue

func _ready() -> void:
	pq = PriorityQueue.new()

	pq.push(5)
	pq.push(4)
	pq.push(6)
	pq.push(11)
	pq.push(2)

	for i: int in range(5):
		print_debug(pq.top())
		pq.pop()
