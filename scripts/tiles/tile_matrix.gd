class_name TileMatrix
extends RefCounted

var _tiles: Array[Array] = []
var _first_tile: Vector2i

func _init(first: Vector2i, last: Vector2i) -> void:
	_first_tile = first
	_tiles.resize(last.y - first.y + 1)

	for row in _tiles:
		row.resize(last.x - first.x + 1)


func has_tile(index: Vector2i) -> bool:
	return Utils.valid_index(_tiles, index.y - _first_tile.y) and Utils.valid_index(_tiles[0], index.x - _first_tile.x)


func get_tile(index: Vector2i) -> Tile:
	if has_tile(index):
		return _tiles[index.y - _first_tile.y][index.x - _first_tile.x]
	return null


func set_tile(index: Vector2i, tile: Tile) -> bool:
	if has_tile(index):
		_tiles[index.y - _first_tile.y][index.x - _first_tile.x] = tile
		return true
	return false


func load_map(map: TileMapLayer) -> Dictionary[StringName, Variant]:
	var data: Dictionary[StringName, Variant] = {
		"start" = Vector2i.ZERO,
		"finish" = Vector2i.ZERO,
	}
	for y in range(_first_tile.y, _tiles.size() + _first_tile.y):
		for x in range(_first_tile.x, _tiles[0].size() + _first_tile.x):
			var tile: Tile
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
			set_tile(Vector2i(x, y), tile)
	return data
