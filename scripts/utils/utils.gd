class_name Utils
extends Object

const INT_MAX = 9223372036854775807

static func valid_index(arr: Array, idx: int) -> bool:
	return idx >= 0 and idx < arr.size()