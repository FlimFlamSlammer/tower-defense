class_name EnergyBlades
extends Tower

var heat: float = 0.0 ## Revolutions per second.

var _attack_cost_buffer: float = 0.0

var _blade_durabilities: Array[int]
var _blade_repair_progresses: Array[float]
var _collider_pivot: ColliderPivot
var _colliders: Array[Area2D]
var _blade_sprites: Array[Sprite2D]

func _process(delta: float) -> void:
	if not _placed: return

	if ("energy" in status_effects):
		var heat_dir: int = 1 if targeting == "Clockwise" else -1

		heat -= sign(heat) * stats.heat_loss * delta
		if enemy_in_range(stats.range):
			var initial_heat: float = heat
			heat += (stats.heat_gain + stats.heat_loss) * delta * heat_dir
			heat = sign(heat) * minf(abs(stats.max_heat), abs(heat))

			var delta_heat: float = abs(heat - initial_heat)
			_attack_cost_buffer += delta_heat * stats.heat_cost
			money_requested.emit(ceili(_attack_cost_buffer), true, func(success: bool) -> void:
				if not success:
					heat = initial_heat
					return
				_attack_cost_buffer -= ceilf(_attack_cost_buffer)
			)
		heat = heat_dir * maxf(heat * heat_dir, 0.0)

		_repair_blades(delta)

	_mutable_data.pivot.rotation += TAU * heat * delta
	_collider_pivot.update_rotation(_mutable_data.pivot.rotation, TAU * heat * delta)


func update_status_effects() -> void:
	super ()
	_initialize_blades()


func place() -> void:
	super ()
	_show_blade_trails()


func save() -> Dictionary[StringName, Variant]:
	for i in range(_blade_durabilities.size()):
		_repair_blade(i, stats.blade_repair_cost)
		_show_blade(i)

	heat = 0.0
	_mutable_data.pivot.rotation = 0.0
	_collider_pivot.update_rotation(_mutable_data.pivot.rotation, 0)


	return super ()


func _on_targeting_changed() -> void:
	_set_blade_trail_direction(targeting == "Clockwise")


func _show_blade_trails() -> void:
	if not _mutable_data.is_node_ready():
		await _mutable_data.ready

	var blades: Array[Node] = _mutable_data.pivot.get_node("Blades").get_children()

	for blade: Node in blades:
		var trail: Trail2D = blade.get_node("Trail2D")
		trail.emitting = true


func _set_blade_trail_direction(dir: bool) -> void:
	if not _mutable_data.is_node_ready():
		await _mutable_data.ready

	var blades: Array[Node] = _mutable_data.pivot.get_node("Blades").get_children()

	for blade: Node in blades:
		var trail_gradient: GradientTexture2D = blade.get_node("Trail2D").texture
		if dir:
			trail_gradient.fill_from = Vector2(0, 0)
			trail_gradient.fill_to = Vector2(0, 1)
		else:
			trail_gradient.fill_from = Vector2(0, 1)
			trail_gradient.fill_to = Vector2(0, 0)


func _initialize_blades() -> void:
	_collider_pivot = _mutable_data.get_node("Colliders")
	_colliders = Array(_collider_pivot.get_children(), TYPE_OBJECT, "Area2D", null)
	_blade_sprites = Array(_mutable_data.get_node("Pivot/Blades").get_children(), TYPE_OBJECT, "Sprite2D", null)

	if (_blade_durabilities.size() != _colliders.size()):
		_blade_durabilities.resize(_colliders.size())
		_blade_durabilities.fill(stats.blade_durability)

		_blade_repair_progresses.resize(_colliders.size())
		_blade_repair_progresses.fill(0.0)

	for i in range(_colliders.size()):
		if not _colliders[i].area_entered.is_connected(_on_blade_hit.bind(i)):
			_colliders[i].area_entered.connect(_on_blade_hit.bind(i))


func _on_blade_hit(area: Area2D, index: int) -> void:
	if _blade_durabilities[index] <= 0 or abs(heat) < 0.5: return

	_blade_durabilities[index] -= 1
	damage_enemy(area, stats.damage)
	if _blade_durabilities[index] <= 0:
		_hide_blade(index)


## Call continuously. Param [delta] is time (in seconds) since last repair.
func _repair_blades(delta: float) -> void:
	for i in range(_blade_durabilities.size()):
		if _blade_durabilities[i] < stats.blade_durability:
			_blade_repair_progresses[i] += stats.blade_repair_speed * delta

			if _blade_durabilities[i] > 0:
				if _blade_repair_progresses[i] >= 1.0:
					_repair_blade(i, floori(_blade_repair_progresses[i]))

			else:
				if _blade_repair_progresses[i] >= stats.blade_durability:
					if _repair_blade(i, stats.blade_durability):
						_blade_repair_progresses[i] = 0.0
						_show_blade(i)
		else:
			_blade_repair_progresses[i] = 0.0


func _repair_blade(blade_index: int, repair_amount: int) -> bool:
	if (_blade_durabilities[blade_index] + repair_amount > stats.blade_durability):
		repair_amount = stats.blade_durability - _blade_durabilities[blade_index]

	var succeeded: PackedByteArray = [true] # lambda capture by reference
	money_requested.emit(ceili(stats.blade_repair_cost * repair_amount * stats.attack_cost), true, func(success: bool) -> void:
		if not success:
			succeeded[0] = false
			return

		_blade_durabilities[blade_index] += repair_amount
		_blade_repair_progresses[blade_index] -= repair_amount
	)

	return succeeded[0]

func _show_blade(i: int) -> void:
	_blade_sprites[i].self_modulate.a = 1.0
	_blade_sprites[i].get_child(0).emitting = true


func _hide_blade(i: int) -> void:
	_blade_sprites[i].self_modulate.a = 0.0
	_blade_sprites[i].get_child(0).emitting = false
