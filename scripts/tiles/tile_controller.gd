class_name TileController
extends TileMapLayer

const EXPECTED_ENEMY_SPEED: float = 1.2 ## Assumption of enemy speed, used for pathfinding.

@export var first_tile: Vector2i
@export var last_tile: Vector2i
@export var arrow_tile_map: TileMapLayer

var start_tile: Vector2i
var finish_tile: Vector2i

var _updated_immunities: Dictionary[Array, bool]

@onready var tiles := TileMatrix.new(first_tile, last_tile)
@onready var wall_tile_map: TileMapLayer = $WallMap

func _ready() -> void:
	var map_data: Dictionary[StringName, Variant] = tiles.load_map(self)
	start_tile = map_data.start
	finish_tile = map_data.finish


func can_place_wall(pos: Vector2i, vertical: bool) -> bool:
	var tile := tiles.get_tile(pos) as PathTile

	if not tile:
		return false

	var adjacent: PathTile
	if vertical:
		if tile.east_wall:
			return false
		adjacent = tiles.get_tile(pos + Vector2i(1, 0)) as PathTile
	else:
		if tile.south_wall:
			return false
		adjacent = tiles.get_tile(pos + Vector2i(0, 1)) as PathTile

	if not adjacent:
		return false

	return true


## Places [param wall] at the specified position. Returns [code]true[/code] if the operation was successful.
func place_wall(pos: Vector2i, vertical: bool, wall: Wall) -> bool:
	if not can_place_wall(pos, vertical):
		return false

	if wall.get_parent():
		wall.reparent(self)
	else:
		add_child(wall)

	wall.tile_map = wall_tile_map
	wall.tile_position = pos
	wall.vertical = vertical

	var tile: PathTile = tiles.get_tile(pos)
	if vertical:
		tile.east_wall = wall
	else:
		tile.south_wall = wall

	wall.place()

	_clear_pathfinding_data()

	return true


## Returns the [Wall] between to tile positions. If the [Wall] doesn't exist, it returns [code]null[/code].
func get_wall_between(origin: Vector2i, target: Vector2i) -> Wall:
	var offset: Vector2i = target - origin

	var target_tile := tiles.get_tile(target) as PathTile
	var origin_tile := tiles.get_tile(origin) as PathTile

	if not target_tile or not origin_tile:
		return null

	if offset.x == 1:
		return origin_tile.east_wall
	elif offset.y == 1:
		return origin_tile.south_wall
	elif offset.x == -1:
		return target_tile.east_wall
	elif offset.y == -1:
		return target_tile.south_wall

	return null


## Returns a dictionary as follows:
## [codeblock]
## {
##     "pos": Vector2i,
##     "vertical": bool,
## }
## [/codeblock]
## where [code]pos[/code] is the tile position of a [Wall] based on the mouse position and [code]vertical[/code] is the orientation of the [Wall].
func get_wall_pos_from_mouse() -> Dictionary[StringName, Variant]:
	var map_pos: Vector2i = wall_tile_map.local_to_map(get_local_mouse_position())
	var wall_pos: Vector2i = Vector2i(map_pos.x, map_pos.y / 2)
	var vertical: bool = not (map_pos.y % 2)

	return {
		"pos": wall_pos,
		"vertical": vertical,
	}


func can_place_tower(pos: Vector2i) -> bool:
	var tile := tiles.get_tile(pos) as TowerTile
	return tile and not tile.tower


## Places [param tower] at [param pos]. Returns [code]true[/code] if the operation was successful.
func place_tower(pos: Vector2i, tower: Tower) -> bool:
	if not can_place_tower(pos):
		return false

	var tile := tiles.get_tile(pos) as TowerTile

	if tower.get_parent():
		tower.reparent(self);
	else:
		add_child(tower)
		
	tower.tile_controller = self
	tower.tile_position = pos
	tile.tower = tower

	tower.tower_modified.connect(_clear_pathfinding_data)
	if Tower.Groups.SUPPORT in tower.get_groups():
		tower.tower_sold.connect(update_support_towers)

	tower.place()

	update_support_towers()

	return true


## Returns the [PathTile] at [param tile_pos]. [br]
## If the pathfinding data for [param immunities] hasn't been generated yet, it will be generated first.
func handle_path_data_request(immunities: Array[Globals.DamageTypes], tile_pos: Vector2i, cb: Callable):
	if not immunities in _updated_immunities:
		_update_paths(immunities)

	cb.call(tiles.get_tile(tile_pos))


## Clears persistent [TowerStatusEffect] from every [Tower], then runs [method SupportTower.give_status_effects] for every [SupportTower].
func update_support_towers():
	for tower: Tower in get_tree().get_nodes_in_group(Tower.Groups.ALL):
		tower.clear_persistent_status_effects()

	var towers: Array[Node] = get_tree().get_nodes_in_group(Tower.Groups.SUPPORT)
	for tower: SupportTower in towers:
		if not tower.is_queued_for_deletion():
			tower.give_status_effects()


# Iterates over all PathTiles and clears their next_tile property.
func _clear_pathfinding_data() -> void:
	for x in range(first_tile.x, last_tile.x + 1):
		for y in range(first_tile.y, last_tile.y + 1):
			var tile := tiles.get_tile(Vector2i(x, y)) as PathTile
			if not tile:
				continue

			tile.next_path.clear()

	_updated_immunities.clear()


# Appends the next_tile property of all tiles that can reach the finish tile based on param immunities.
func _update_paths(immunities: Array[Globals.DamageTypes]) -> void:
	_update_danger_levels(immunities)

	var visited: Dictionary[Vector2i, bool]
	var pq := PriorityQueue.new(
		func compare(a: Array, b: Array) -> bool:
			if a[1] == b[1]:
				return a[2] > b[2]
			return a[1] > b[1]
	)
	pq.push([finish_tile, 0, 0, finish_tile])
	# data format:
	# [tile, danger level, distance from exit]

	while pq.size():
		var data: Array = pq.top()
		pq.pop()

		if data[0] in visited: continue
		visited[data[0]] = true

		var tile: PathTile = tiles.get_tile(data[0])
		tile.next_path[immunities] = data[3]
		tile.distance_from_finish = data[2]

		# Debug arrows
		var atlas_coords: Dictionary[Vector2i, Vector2i]
		atlas_coords[Vector2i.ZERO] = Vector2i(0, 0)
		atlas_coords[Vector2i.LEFT] = Vector2i(0, 0)
		atlas_coords[Vector2i.DOWN] = Vector2i(1, 0)
		atlas_coords[Vector2i.RIGHT] = Vector2i(2, 0)
		atlas_coords[Vector2i.UP] = Vector2i(3, 0)
		arrow_tile_map.set_cell(data[0], 0, atlas_coords[data[0] - data[3]])

		_push_pathfinding_data(pq, data, Vector2i.UP)
		_push_pathfinding_data(pq, data, Vector2i.DOWN)
		_push_pathfinding_data(pq, data, Vector2i.LEFT)
		_push_pathfinding_data(pq, data, Vector2i.RIGHT)

	_updated_immunities[immunities] = true


# Iterates over every [Tower] to calculate the danger level of every [PathTile].
func _update_danger_levels(immunities: Array[Globals.DamageTypes]) -> void:
	# reset current danger levels
	for x in range(first_tile.x, last_tile.x + 1):
		for y in range(first_tile.y, last_tile.y + 1):
			var tile := tiles.get_tile(Vector2i(x, y)) as PathTile
			if not tile:
				continue

			tile.danger_level = 0

	var towers: Array[Node] = get_tree().get_nodes_in_group(Tower.Groups.ATTACKING)

	for tower: Tower in towers:
		tower.update_danger_levels(Tower.Groups.ATTACKING, immunities)

	towers = get_tree().get_nodes_in_group(Tower.Groups.SETUP)

	for tower: Tower in towers:
		tower.update_danger_levels(Tower.Groups.SETUP, immunities)


func _push_pathfinding_data(pq: PriorityQueue, data: Array, offset: Vector2i) -> void:
	var new_data: Array = []
	new_data.resize(4)

	new_data[0] = data[0] + offset

	var new_tile := tiles.get_tile(new_data[0]) as PathTile
	if not new_tile:
		return

	var origin_tile := tiles.get_tile(data[0]) as PathTile

	# Calculate danger level
	new_data[1] = data[1] + (new_tile.danger_level / EXPECTED_ENEMY_SPEED)

	var wall_between: Wall = get_wall_between(data[0], new_data[0])
	if wall_between:
		new_data[1] += wall_between.stats.health

	# Calculate distance from finish
	new_data[2] = data[2] + 1
	new_data[3] = data[0]

	pq.push(new_data)
