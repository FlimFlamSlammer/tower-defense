extends Sprite2D

@export var thickness: float = 1.0
@export var color := Vector4(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	material = preload("uid://b4s2mxmhcjh2v").duplicate()

func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return

	var scaled_thickness: float = thickness / global_scale.x
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("line_thickness", scaled_thickness)
	shader_material.set_shader_parameter("line_color", color)
