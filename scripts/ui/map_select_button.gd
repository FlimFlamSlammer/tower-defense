class_name MapSelectButton
extends Button

const _TILE_MAP_SCALE: float = 0.1875
const _GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")

@export var map_name: String = ""
@export var tile_map_scene: PackedScene

@onready var sub_viewport: Node = %SubViewport
@onready var label: Label = %Label

func _ready() -> void:
	if tile_map_scene:
		var tile_map: TileMapLayer = tile_map_scene.instantiate()
		tile_map.scale *= _TILE_MAP_SCALE

		sub_viewport.add_child(tile_map)

	label.text = map_name.capitalize()


func _on_pressed() -> void:
	SceneLoader.change_scene(_GAME_SCENE, func(game: GameProvider) -> void:
		game.map_name = map_name
	)
