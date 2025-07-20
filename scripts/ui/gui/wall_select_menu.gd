class_name WallSelectMenu
extends ClosableMenu

var _selected_wall: Wall

@onready var _wall_label: Label = %WallLabel
@onready var _sell_button: Button = %SellButton
@onready var _sell_price_label: Label = %SellLabel

func close(instant: bool = false) -> void:
	_disconnect_previous_wall()
	super (instant)


func update_wall(wall: Wall) -> void:
	_disconnect_previous_wall()
	_selected_wall = wall

	_wall_label.text = _selected_wall.wall_name

	_selected_wall.damaged.connect(_update)
	_sell_button.pressed.connect(_selected_wall.sell)

	_update()


func _update(health: float = INF) -> void:
	if health == 0:
		close()

	_sell_price_label.text = str(_selected_wall.get_sell_value())


func _disconnect_previous_wall() -> void:
	if _selected_wall and _selected_wall.damaged.is_connected(_update):
		_selected_wall.damaged.disconnect(_update)
		_sell_button.pressed.disconnect(_selected_wall.sell)
