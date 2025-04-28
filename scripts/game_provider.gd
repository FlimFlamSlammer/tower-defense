class_name GameProvider
extends Node

signal lives_changed(lives: int)
signal money_changed(money: int)

const _MAP_SCENE_DIR: String = "res://scenes/maps/"

var map_name: String = "valley"

var lives: int = 100:
	set(val):
		lives = val
		_gui.lives_display.value = str(lives)
		lives_changed.emit(val)

var money: int = 2100:
	set(val):
		money = val
		_gui.money_display.value = str(money)
		money_changed.emit(val)

@onready var _spawner: Spawner = %Spawner
@onready var _gui: GUIRoot = $GUILayer/GUI
@onready var _screen_menu_layer: ScreenMenuLayer = $ScreenMenuLayer
@onready var _tile_controller: TileController = Globals.get_tile_controller(get_tree())
@onready var _start_wave_button: Button = get_tree().get_nodes_in_group("start_wave_button")[-1]

func _ready() -> void:
	# initialize map scene
	var map_scene_path: String = _MAP_SCENE_DIR.path_join("%s.tscn" % map_name)
	var map_scene: PackedScene = load(map_scene_path)

	if not map_scene:
		print_debug("Map scene not found in path '%s'" % map_scene_path)
		return

	var map: TileMapLayer = map_scene.instantiate()
	map.name = "TileMap"
	map.z_index = -2048
	_tile_controller.add_child(map)

	_tile_controller.load_map()

	# connect signals
	_start_wave_button.pressed.connect(_spawner.start_wave)

	_spawner.enemy_spawned.connect(func(enemy: Enemy) -> void:
		enemy.leaked.connect(func(health: float) -> void:
			lives -= max(roundi(health), 1)
		)
		enemy.path_data_requested.connect(_tile_controller.handle_path_data_request)
		enemy.died.connect(func() -> void:
			if not _are_enemies_remaining() and not _spawner.spawning:
				money += _get_wave_bonus(_spawner.wave)
				_start_wave_button.disabled = false

				_save_game()
		)
	)

	_spawner.wave_started.connect(func() -> void:
		_start_wave_button.disabled = true
	)

	_gui.money_requested.connect(_handle_money_request)

	_gui.tower_placed.connect(func(tower: Tower) -> void:
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
	return 400 + (30 * wave)


func _pause_game() -> void:
	get_tree().paused = true


func _resume_game() -> void:
	get_tree().paused = false


func _save_game() -> void:
	var save_file: FileAccess = _get_save_file(FileAccess.WRITE)

	var game_data: Dictionary[StringName, Variant] = {
		money = money,
		lives = lives,
		wave = _spawner.wave,
	}

	save_file.store_var(game_data)

	var data_array: Array[Dictionary]

	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	data_array.resize(towers.size())
	for i: int in range(towers.size()):
		var data: Dictionary[StringName, Variant] = towers[i].save()
		data_array[i] = data

	save_file.store_var(data_array)

	var walls: Array[Node] = get_tree().get_nodes_in_group("walls")
	data_array.resize(walls.size())
	for i: int in range(walls.size()):
		var data: Dictionary[StringName, Variant] = walls[i].save()
		data_array[i] = data

	save_file.store_var(data_array)


func _load_game() -> void:
	var save_file: FileAccess = _get_save_file(FileAccess.READ)
	if save_file == null: return

	var game_data: Variant = save_file.get_var()
	if not game_data is Dictionary: _reset_game()
	money = game_data.money
	lives = game_data.lives
	_spawner.wave = game_data.wave

	var data_array: Variant

	data_array = save_file.get_var()
	if not data_array is Array: _reset_game()
	for tower_data: Dictionary in data_array:
		var tower_scene: PackedScene = load(tower_data.scene_path)
		var tower: Tower = tower_scene.instantiate()

		_tile_controller.place_tower(tower_data.position, tower)
		tower.load(tower_data)

	data_array = save_file.get_var()
	if not data_array is Array: _reset_game()
	for wall_data: Dictionary in data_array:
		var wall_scene: PackedScene = load(wall_data.scene_path)
		var wall: Wall = wall_scene.instantiate()

		_tile_controller.place_wall(wall_data.position, wall_data.vertical, wall)
		wall.load(wall_data)

	_gui.load()
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	for tower: Tower in towers:
		tower.money_requested.connect(_handle_money_request)


func _reset_game() -> void:
	DirAccess.remove_absolute(Globals.SAVE_PATH.path_join("save-%s" % map_name))
	SceneLoader.change_scene(load(scene_file_path), func(game: GameProvider) -> void:
		game.map_name = map_name
	)


func _exit_game() -> void:
	SceneLoader.change_scene(load(Globals.MAIN_MENU_SCENE_PATH))


func _get_save_file(flags: int) -> FileAccess:
	return FileAccess.open(Globals.SAVE_PATH.path_join("save-%s" % map_name), flags)
