class_name GameProvider
extends Node

var lives: float = 100.0:
	set(val):
		lives = val
		gui.lives_display.value = str(roundi(lives))
var money: float = 200.0:
	set(val):
		money = val
		gui.money_display.value = str(roundi(money))

@onready var spawner: Spawner = $MainTileMap/Spawner
@onready var gui: GUIRoot = $GUILayer/GUI

func _ready() -> void:
	spawner.enemySpawned.connect(func(enemy: Enemy):
		enemy.enemyLeaked.connect(func(health: float):
			lives -= health
		)
	)
