extends TileMapLayer

@export var first_tile: Vector2i
@export var last_tile: Vector2i

var tiles := TileMatrix.new(first_tile, last_tile)

var start_tile: Vector2i
var finish_tile: Vector2i

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


func update_paths() -> void:
	# reset pathfinding data
	for y: int in range(first_tile.y, last_tile.y):
		for x: int in range(first_tile.x, last_tile.x):
			var tile := tiles.get_tile(Vector2i(x, y)) as PathTile
			if not tile:
				continue

			tile.reset_pathfinding_data()

	var visited: Dictionary
	var pq := PriorityQueue.new(
		func compare(a: Array, b: Array) -> bool:
			if a[1] == b[1]:
				return a[2] > b[2]
			return a[1] > b[1]
	)
	pq.push([finish_tile, 0, 0])
	visited[finish_tile] = true

	while pq.size():
		var pos: Vector2i = pq.top()[0]

		var tile := tiles.get_tile(pos) as PathTile

		_push_pathfinding_data(visited, pq, pq.top(), Vector2i.UP)

		
func _push_pathfinding_data(visited: Dictionary, pq: PriorityQueue, data: Array, offset: Vector2i) -> void:
	var new_data: Array = []
	new_data.resize(3)

	new_data[0] = data[0] + offset

	if visited.has(new_data[0]):
		return
	
	var new_tile := tiles.get_tile(new_data[0]) as PathTile
	if not new_tile:
		return

	new_data[1] = data[1] + new_tile.danger_level
	new_data[2] = data[2] + 1

	pq.push(new_data)
	visited[new_data[0]] = true