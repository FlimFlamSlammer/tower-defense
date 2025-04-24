class_name GameProvider
extends Node

signal lives_changed(lives: int)
signal money_changed(money: int)

@export var map_name: String = "valley"

var lives: int = 100:
	set(val):
		lives = val
		_gui.lives_display.value = str(lives)
		lives_changed.emit(val)

var money: int = 2000:
	set(val):
		money = val
		_gui.money_display.value = str(money)
		money_changed.emit(val)

@onready var _spawner: Spawner = $MainTileMap/Spawner
@onready var _gui: GUIRoot = $GUILayer/GUI
@onready var _screen_menu_layer: ScreenMenuLayer = $ScreenMenuLayer
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)
@onready var _start_wave_button: Button = get_tree().get_first_node_in_group("start_wave_button")

func _ready() -> void:
	_start_wave_button.pressed.connect(func():
		_spawner.start_wave()
	)

	_spawner.enemy_spawned.connect(func(enemy: Enemy):
		enemy.leaked.connect(func(health: float):
			lives -= max(roundi(health), 1)
		)
		enemy.path_data_requested.connect(_tile_controller.handle_path_data_request)
		enemy.died.connect(func():
			if not _are_enemies_remaining() and not _spawner.spawning:
				money += _get_wave_bonus(_spawner.wave)
				_start_wave_button.disabled = false

				_save_game()
		)
	)

	_spawner.wave_started.connect(func():
		_start_wave_button.disabled = true
	)

	_gui.money_requested.connect(_handle_money_request)

	_gui.tower_placed.connect(func(tower: Tower):
		tower.money_requested.connect(_handle_money_request)
	)

	_screen_menu_layer.pause_requested.connect(_pause_game)
	_screen_menu_layer.resume_requested.connect(_resume_game)

	money = money # force update money display
	lives = lives # force update lives display

	_load_game()


func _handle_money_request(amount: int, spend_money: bool, cb: Callable) -> void:
	cb.call(money >= amount)
	if money >= amount and spend_money:
		money -= amount


func _are_enemies_remaining() -> bool:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for enemy: Enemy in enemies:
		if not enemy.is_queued_for_deletion():
			return true

	return false


func _get_wave_bonus(wave: int) -> int:
	return 500 + (30 * wave)


func _pause_game() -> void:
	get_tree().paused = true


func _resume_game() -> void:
	get_tree().paused = false


func _save_game() -> void:
	var save_file: FileAccess = _get_save_file(FileAccess.WRITE)

	var game_data: Dictionary = {
		"money": money,
		"lives": lives,
		"wave": _spawner.wave,
	}

	save_file.store_var(game_data)

	var data_array: Array[Dictionary]

	var towers = get_tree().get_nodes_in_group("towers")
	data_array.resize(towers.size())
	for i: int in range(towers.size()):
		var data: Dictionary = towers[i].save()
		data_array[i] = data

	save_file.store_var(data_array)

	var walls = get_tree().get_nodes_in_group("walls")
	data_array.resize(walls.size())
	for i: int in range(walls.size()):
		var data: Dictionary = walls[i].save()
		data_array[i] = data

	save_file.store_var(data_array)


func _load_game() -> void:
	var save_file: FileAccess = _get_save_file(FileAccess.READ)
	if save_file == null: return

	var game_data: Dictionary = Utils.get_var_safe(save_file, TYPE_DICTIONARY)
	if game_data == null: _reset_game()
	money = game_data.money
	lives = game_data.lives
	_spawner.wave = game_data.wave

	var data_array: Array

	data_array = Utils.get_var_safe(save_file, TYPE_ARRAY)
	if data_array == null: _reset_game()
	for tower_data: Dictionary in data_array:
		var tower_scene: PackedScene = load(tower_data.scene_path)
		var tower: Tower = tower_scene.instantiate()

		_tile_controller.place_tower(tower_data.position, tower)
		tower.load(tower_data)

	data_array = Utils.get_var_safe(save_file, TYPE_ARRAY)
	if data_array == null: _reset_game()
	for wall_data: Dictionary in data_array:
		var wall_scene: PackedScene = load(wall_data.scene_path)
		var wall: Wall = wall_scene.instantiate()

		_tile_controller.place_wall(wall_data.position, wall_data.vertical, wall)
		wall.stats.health = wall_data.health

	_gui.load()
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	for tower: Tower in towers:
		tower.money_requested.connect(_handle_money_request)


func _reset_game() -> void:
	var dir = DirAccess.remove_absolute(Globals.SAVE_PATH.path_join("save-" + map_name))


func _get_save_file(flags: int) -> FileAccess:
	return FileAccess.open(Globals.SAVE_PATH.path_join("save-" + map_name), flags)
