class_name Globals
extends Object

const TILE_CONTROLLER_PATH: NodePath = "/root/Map/MainTileMap"

const TowerGroups: Dictionary = {
	"ATTACKING" = "attacking_towers",
	"SETUP" = "setup_towers",
	"SUPPORT" = "support_towers",
}

static func tween_properties(object: Object, properties: Array[NodePath], final_vals: Array[Variant], duration: float, ease_type: int, trans_type: int) -> void:
	for i in range(properties.size()):
		var tween = object.create_tween()
		print(properties[i], final_vals[i])
		tween.tween_property(object, properties[i], final_vals[i], duration).set_ease(ease_type).set_trans(trans_type)
