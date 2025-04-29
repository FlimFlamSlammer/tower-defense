class_name Wall
extends Sprite2D

signal sold()
signal damaged(new_health: float)
signal clicked()
signal money_requested(amount: int, spend: bool, cb: Callable) ## Emits when the tower requests an action that uses money. Call param cb to confirm the action.

const _SELL_VALUE = 0.7

@export var wall_name: StringName
@export var base_stats: Dictionary[StringName, Variant]
@export var cost: int

var tile_map: TileMapLayer

var tile_position: Vector2i:
	set(val):
		tile_position = val
		position = tile_map.map_to_local(Vector2i(val.x, val.y * 2 + int(not vertical)))


var vertical: bool:
	set(val):
		vertical = val
		if vertical:
			rotation = 0.0
		else:
			rotation = TAU * 0.25
		tile_position = tile_position

@onready var stats: Dictionary[StringName, Variant] = base_stats.duplicate()
@onready var _base_health: float = stats.health
@onready var _range_animations: AnimationPlayer = $RangeAnimation
@onready var _click_area: Control = $ClickArea

func place() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_click_area.mouse_filter = Control.MOUSE_FILTER_STOP


func set_display_invalid() -> void: ## Changes the color to represent an invalid placement position. Use when the wall is in placement mode.
	modulate = Color(1.0, 0.1, 0.1, 0.4)


func set_display_valid() -> void: ## Changes the color to represent a valid placement position. Use when the wall is in placement mode.
	modulate = Color(1.0, 1.0, 1.0, 0.4)


func select() -> void:
	_range_animations.play("show_range")


func deselect() -> void:
	_range_animations.play("hide_range")


func save() -> Dictionary[StringName, Variant]:
	var save_dict: Dictionary[StringName, Variant] = {
		scene_path = scene_file_path,
		position = tile_position,
		vertical = vertical,
		health = stats.health,
	}
	return save_dict


func load(data: Dictionary[StringName, Variant]) -> void:
	stats.health = data.health


func hit(damage: float) -> void:
	stats.health -= damage
	damaged.emit(stats.health)
	if stats.health <= 0:
		queue_free()


func sell() -> void:
	money_requested.emit(-get_sell_value(), true, Utils.null_callable)
	sold.emit()
	queue_free()


func get_sell_value() -> int:
	return floori(cost * _SELL_VALUE * stats.health / _base_health)


func _on_input_received(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()
