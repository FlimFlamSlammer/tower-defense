extends Node

func change_scene(new_scene: PackedScene, cb: Callable = Utils.null_callable) -> void:
	var current_scene: Node = get_tree().root.get_child(-1)
	current_scene.queue_free()

	var scene: Node = new_scene.instantiate()
	get_parent().add_child.call_deferred(scene)

	cb.call(scene)

	get_tree().paused = false
