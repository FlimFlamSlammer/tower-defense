class_name TileController
extends TileMapLayer

@export var first_tile: Vector2i
@export var last_tile: Vector2i
@export var arrow_tile_map: TileMapLayer

var start_tile: Vector2i
var finish_tile: Vector2i

@onready var tiles := TileMatrix.new(first_tile, last_tile)

func _ready() -> void:
	var map_data: Dictionary = tiles.load_map(self)
	start_tile = map_data.start
	finish_tile = map_data.finish

	update_paths()


func can_place_wall(pos: Vector2i, south: bool) -> bool:
	var tile := tiles.get_tile(pos) as PathTile

	if not tile:
		return false

	var adjacent: PathTile
	if south:
		if tile.southWall:
			return false
		adjacent = tiles.get_tile(pos + Vector2i(0, 1)) as PathTile
	else:
		if tile.eastWall:
			return false
		adjacent = tiles.get_tile(pos + Vector2i(1, 0)) as PathTile

	if not adjacent:
		return false

	return true


func place_wall(pos: Vector2i, south: bool, wall: Wall) -> bool:
	if not can_place_wall(pos, south):
		return false

	var tile := tiles.get_tile(pos) as PathTile
	if south:
		tile.southWall = wall
	else:
		tile.eastWall = wall

	return true


func remove_wall(pos: Vector2i, south: bool) -> bool:
	var tile := tiles.get_tile(pos) as PathTile

	if not tile:
		return false

	if south:
		if not tile.southWall:
			return false
		else:
			tile.southWall = null
	else:
		if not tile.eastWall:
			return false
		else:
			tile.eastWall = null

	return true


func place_tower(pos: Vector2i, tower: Tower) -> bool:
	if not _can_place_tower(pos):
		return false

	var tile := tiles.get_tile(pos) as TowerTile

	tower.tile_position = pos
	tower.position = map_to_local(pos)
	tower.tower_modified.connect(update_danger_levels)
	tile.tower = tower
	tower.place()

	return true


func remove_tower(pos: Vector2i) -> bool:
	var tile := tiles.get_tile(pos) as TowerTile
	if tile and tile.tower:
		tile.tower.queue_free()
		tile.tower = null
		update_paths()
		return true
	return false


func update_paths() -> void:
	var visited: Dictionary[Vector2i, bool]
	var pq := PriorityQueue.new(
		func compare(a: Array, b: Array) -> bool:
			if a[1] == b[1]:
				return a[2] > b[2]
			return a[1] > b[1]
	)
	pq.push([finish_tile, 0, 0])
	# data format:
	# [tile, danger level, distance from exit]

	visited[finish_tile] = true

	while pq.size():
		var data = pq.top()
		pq.pop()

		_push_pathfinding_data(visited, pq, data, Vector2i.UP)
		_push_pathfinding_data(visited, pq, data, Vector2i.DOWN)
		_push_pathfinding_data(visited, pq, data, Vector2i.LEFT)
		_push_pathfinding_data(visited, pq, data, Vector2i.RIGHT)


func update_danger_levels() -> void:
	# reset current danger levels
	for x in range(first_tile.x, last_tile.x + 1):
		for y in range(first_tile.y, last_tile.y + 1):
			var tile := tiles.get_tile(Vector2i(x, y)) as PathTile
			if not tile:
				continue

			tile.danger_level = 0

	var towers: Array[Node] = get_tree().get_nodes_in_group(Globals.TowerGroups.ATTACKING)

	for tower: Tower in towers:
		tower.update_danger_levels(Globals.TowerGroups.ATTACKING)

	towers = get_tree().get_nodes_in_group(Globals.TowerGroups.SETUP)

	for tower: Tower in towers:
		tower.update_danger_levels(Globals.TowerGroups.SETUP)

	update_paths()


func _can_place_tower(pos: Vector2i) -> bool:
	var tile := tiles.get_tile(pos) as TowerTile
	return tile and not tile.tower


func _push_pathfinding_data(visited: Dictionary, pq: PriorityQueue, data: Array, offset: Vector2i) -> void:
	var new_data: Array = []
	new_data.resize(3)

	new_data[0] = data[0] + offset

	if visited.has(new_data[0]): return

	var new_tile := tiles.get_tile(new_data[0]) as PathTile
	if not new_tile:
		return

	var origin_tile := tiles.get_tile(data[0]) as PathTile

	if (
		(offset.x < 0 and new_tile.east_wall)
		or (offset.y < 0 and new_tile.south_wall)
		or (offset.x > 0 and origin_tile.east_wall)
		or (offset.y > 0 and origin_tile.south_wall)
	): return

	new_data[1] = data[1] + new_tile.danger_level
	new_data[2] = data[2] + 1
	new_tile.distance_from_finish = new_data[2]

	pq.push(new_data)
	visited[new_data[0]] = true

	new_tile.next_path = data[0]

	# debug arrows
	var atlas_coords: Dictionary[Vector2i, Vector2i]
	atlas_coords[Vector2i.LEFT] = Vector2i(0, 0)
	atlas_coords[Vector2i.DOWN] = Vector2i(1, 0)
	atlas_coords[Vector2i.RIGHT] = Vector2i(2, 0)
	atlas_coords[Vector2i.UP] = Vector2i(3, 0)

	arrow_tile_map.set_cell(new_data[0], 0, atlas_coords[offset])
