class_name SupportTower
extends Tower

func _can_affect_tower(tower: Tower, status_effect: TowerStatusEffect) -> bool:
	return true


func update_status_effects() -> void:
	super ()
	give_status_effects()


## Applies all status effects in child [code]StatusEffects[/code] to nearby towers.
func give_status_effects() -> void:
	if not _placed: return

	var status_effects_to_give: Array[Node] = _mutable_data.get_node("StatusEffects").get_children()

	_run_for_tiles_in_range(func(tile: Tile, overlap_ratio: float) -> void:
		if overlap_ratio < 0.5:
			return

		if not tile is TowerTile:
			return

		if not tile.tower:
			return

		var tower: Tower = tile.tower
		var tower_changed: bool = false

		for status_effect: TowerStatusEffect in status_effects_to_give:
			if "attack_status_effects" in status_effect.stat_setters:
				var effect_paths: Array = status_effect.stat_setters.attack_status_effects

				for i: int in range(effect_paths.size()):
					if effect_paths[i] is NodePath:
						effect_paths[i] = status_effect.get_node(effect_paths[i])

				if status_effect.id in tower.status_effects \
						and tower.status_effects[status_effect.id].priority == status_effect.priority:
					tower.remove_status_effect(status_effect.id)


			if _can_affect_tower(tower, status_effect):
				tower_changed = tower_changed or tower.apply_status_effect(status_effect.duplicate(), false)

		if tower_changed:
			tower.update_status_effects()
	)
