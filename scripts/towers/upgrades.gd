class_name Upgrades
extends Node

func get_upgrade(path: int, tier: int) -> Upgrade:
	return get_child(path).get_child(tier - 1)
