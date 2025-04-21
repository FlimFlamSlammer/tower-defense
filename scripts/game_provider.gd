class_name GameProvider
extends Node

signal lives_changed(lives: int)
signal money_changed(money: int)

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

var wave_running: bool = false:
	set(val):
		wave_running = val
		_start_wave_button.disabled = val


@onready var _spawner: Spawner = $MainTileMap/Spawner
@onready var _gui: GUIRoot = $GUILayer/GUI
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)
@onready var _start_wave_button: Button = get_tree().get_first_node_in_group("start_wave_button")

func _ready() -> void:
	_start_wave_button.pressed.connect(func():
		_spawner.start_wave()
		wave_running = true
	)

	_spawner.enemy_spawned.connect(func(enemy: Enemy):
		enemy.leaked.connect(func(health: float):
			lives -= max(roundi(health), 1)
		)
		enemy.path_data_requested.connect(_tile_controller.handle_path_data_request)
		enemy.died.connect(func():
			wave_running = _is_wave_running()

			if not wave_running:
				money += _get_wave_bonus(_spawner.wave)
		)
	)

	_gui.money_requested.connect(_handle_money_request)

	_gui.tower_placed.connect(func(tower: Tower):
		tower.money_requested.connect(_handle_money_request)
	)

	money = money # force update money display
	lives = lives # force update lives display


func _handle_money_request(amount: int, spend_money: bool, cb: Callable) -> void:
	cb.call(money >= amount)
	if money >= amount and spend_money:
		money -= amount


func _is_wave_running() -> bool:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for enemy: Enemy in enemies:
		if not enemy.is_queued_for_deletion():
			return true

	return false


func _get_wave_bonus(wave: int):
	return 500 + (50 * wave)
