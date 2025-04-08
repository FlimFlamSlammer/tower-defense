class_name GameProvider
extends Node

var lives: int = 100:
	set(val):
		lives = val
		gui.lives_display.value = str(lives)

var money: int = 2000:
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

	gui.tower_placed.connect(func(tower: Tower):
		money -= tower.price
		tower.tower_used_money.connect(func(amount: int):
			money -= amount
		)
	)
	
	money = money # update money display
	lives = lives # update lives display
