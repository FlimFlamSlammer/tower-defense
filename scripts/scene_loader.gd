extends Node

func _ready() -> void:
	var current_scene: Node = get_tree().root.get_child(-1)

	if current_scene.has_signal("scene_change_requested"):
		current_scene.connect("scene_change_requested", _change_scene)


func _change_scene(new_scene: PackedScene):
	var current_scene: Node = get_tree().root.get_child(-1)
	current_scene.queue_free()

	var scene: Node = new_scene.instantiate()
	add_sibling.call_deferred(scene)

	if scene.has_signal("scene_change_requested"):
		scene.connect("scene_change_requested", _change_scene)

	get_tree().paused = false
