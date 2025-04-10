class_name GameProvider
extends Node

signal lives_changed(lives: int)
signal money_changed(money: int)

var lives: int = 100:
	set(val):
		lives = val
		gui.lives_display.value = str(lives)
		lives_changed.emit(val)

var money: int = 200000:
	set(val):
		money = val
		gui.money_display.value = str(money)
		money_changed.emit(val)

@onready var spawner: Spawner = $MainTileMap/Spawner
@onready var gui: GUIRoot = $GUILayer/GUI

func _ready() -> void:
	spawner.enemy_spawned.connect(func(enemy: Enemy):
		enemy.enemy_leaked.connect(func(health: float):
			lives -= max(roundi(health), 1)
		)
	)

	gui.money_requested.connect(_handle_money_request)

	gui.tower_placed.connect(func(tower: Tower):
		tower.money_requested.connect(_handle_money_request)
	)

	money = money # force update money display
	print(money)
	lives = lives # force update lives display


func _handle_money_request(amount: int, spend_money: bool, cb: Callable):
	cb.call(money >= amount)
	if money >= amount and spend_money:
		money -= amount
