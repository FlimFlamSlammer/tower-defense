class_name Upgrades
extends Resource

@export var upgrade_paths: Array[Array]

func get_upgrade(path: int, tier: int) -> Upgrade:
	return upgrade_paths[path][tier - 1]
