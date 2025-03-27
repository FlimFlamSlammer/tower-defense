class_name GameProvider
extends Node

var lives: int = 100:
	set(val):
		lives = val
		gui.lives_display.value = str(lives)

var money: int = 200:
	set(val):
		money = val
		gui.money_display.value = str(money)

@onready var spawner: Spawner = $MainTileMap/Spawner
@onready var gui: GUIRoot = $GUILayer/GUI

func _ready() -> void:
	spawner.enemySpawned.connect(func(enemy: Enemy):
		enemy.enemyLeaked.connect(func(health: float):
			lives -= max(roundi(health), 1)
		)
	)
	gui.towerPlaced.connect(func(tower: Tower):
		money -= tower.price
	)
