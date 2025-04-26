class_name Utils
extends Object

const INT_MAX = 9223372036854775807
const INT_MIN = -9223372036854775808

static var null_callable: Callable = func(_0: Variant = null, _1: Variant = null, _2: Variant = null, _3: Variant = null, _4: Variant = null) -> void: pass

static func valid_index(arr: Array, idx: int) -> bool:
	return idx >= 0 and idx < arr.size()


static func tween_properties(object: Object, properties: Array[NodePath], final_vals: Array[Variant], duration: float, ease_type: int, trans_type: int) -> void:
	for i in range(properties.size()):
		var tween: Tween = object.create_tween()
		tween.tween_property(object, properties[i], final_vals[i], duration).set_ease(ease_type).set_trans(trans_type)
