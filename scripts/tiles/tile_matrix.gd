class_name TileMatrix
extends RefCounted

var _tiles: Array[Array] = []
var _offset: Vector2i

func _init(first: Vector2i, last: Vector2i) -> void:
	_offset = -first
	_tiles.resize(last.y - first.y + 1)

	for row in _tiles:
		row.resize(last.x - first.x + 1)


func get_tile(index: Vector2i) -> Tile:
	if Utils.valid_index(_tiles, index.y + _offset.y) and Utils.valid_index(_tiles[0], index.x + _offset.x):
		return _tiles[index.y + _offset.y][index.x + _offset.x]
	return null


func load_map(map: TileMapLayer) -> Dictionary:
	var data: Dictionary = {
		"start" = Vector2i.ZERO,
		"finish" = Vector2i.ZERO,
	}
	for y: int in range(_offset.y, _tiles.size() - _offset.y):
		for x: int in range(_offset.x, _tiles[0].size() - _offset.x):
			var tile: Tile = get_tile(Vector2i(x, y))

			var tile_type: String = map.get_cell_tile_data(Vector2i(x, y)).get_custom_data("type")
			match tile_type:
				"tower":
					tile = TowerTile.new()
				"path":
					tile = PathTile.new()
				"barrier":
					tile = Tile.new()
				"start":
					tile = PathTile.new()
					data.start = Vector2i(x, y)
				"finish":
					tile = PathTile.new()
					data.finish = Vector2i(x, y)
	return data
