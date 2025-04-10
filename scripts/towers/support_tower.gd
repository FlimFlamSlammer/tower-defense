class_name SupportTower
extends Tower

func _can_affect_tower(tower: Tower, status_effect: TowerStatusEffect) -> bool:
	return true


func update(do_not_update_paths: bool = false) -> void:
	super (true)
	run_for_tiles_in_range(func(tile: Tile, overlap_ratio: float):
		if overlap_ratio < 0.5:
			return

		if not tile is TowerTile:
			return

		if not tile.tower:
			return

		var tower: Tower = tile.tower
		var status_effects: Array[Node] = _mutable_data.get_node("StatusEffects").get_children()

		for status_effect: TowerStatusEffect in status_effects:
			if _can_affect_tower(tower, status_effect):
				tower.apply_status_effect(status_effect.duplicate(), false)
	)
	if not do_not_update_paths:
		update_paths.emit()
