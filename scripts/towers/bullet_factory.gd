class_name BulletFactory
extends SupportTower

func _can_affect_tower(tower: Tower, _status_effect: TowerStatusEffect) -> bool:
	return Tower.Groups.USES_BULLET in tower.get_groups()