class_name Bullet
extends RayCastProjectile

@export var shrapnel_speed: float = 6000.0
@export var shrapnel_spread: float = 0.5
@export var shrapnel_spread_variation: float = 0.2
@export var shrapnel_damage_type: Globals.DamageTypes = Globals.DamageTypes.SHARP
@export var shrapnel_scene: PackedScene

func _on_collision(area: Area2D) -> void:
	super (area)

	if _pierce_used == stats.pierce and "shrapnel_amount" in stats:
		for i in range(stats.shrapnel_amount):
			var shrapnel: AreaProjectile = shrapnel_scene.instantiate()
			shrapnel.stats = {
				damage = stats.shrapnel_damage,
				projectile_speed = shrapnel_speed,
				damage_type = shrapnel_damage_type,
				pierce = 1,
			}
			shrapnel.movement_dir = movement_dir \
					+ (-shrapnel_spread * 0.5 + (float(i) / (stats.shrapnel_amount - 1) * shrapnel_spread)) \
					+ (randf_range(-shrapnel_spread_variation, shrapnel_spread_variation) * 0.5)
			shrapnel.position = _last_pos
			if area as Enemy:
				shrapnel.add_exception(area as Enemy)
			add_sibling(shrapnel)
