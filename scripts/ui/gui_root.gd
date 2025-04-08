class_name GUIRoot
extends Control

signal money_requested(amount: int, spend: bool, cb: Callable)
signal tower_placed(tower: Tower)

const MENU_CLOSED_OFFSET: float = 100.0

var selected_tower: Tower

var is_placing: bool = false
var is_selecting: bool = false
var is_tower_selector_open: bool = false

@onready var _tower_menu: ClosableMenu = $TowerMenu
@onready var _upgrade_menu: UpgradeMenu = $UpgradeMenu
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)
@onready var _top_bar: HBoxContainer = $TopBar
@onready var lives_display: ResourceDisplay = _top_bar.get_node("LivesDisplay")
@onready var money_display: ResourceDisplay = _top_bar.get_node("MoneyDisplay")

func _ready() -> void:
	var tower_buttons: Array[Node] = get_tree().get_nodes_in_group("tower_buttons")
	for button: TowerButton in tower_buttons:
		button.tower_button_pressed.connect(_on_tower_button_pressed)

	_tower_menu.closed_position.position.y = MENU_CLOSED_OFFSET
	_tower_menu.close(true)
	_tower_menu.on_open = cancel_tower_placement

	_upgrade_menu.closed_position.position_inverted.x = - MENU_CLOSED_OFFSET
	_upgrade_menu.close(true)


func _process(_delta: float) -> void:
	if is_placing:
		var pos: Vector2i = _tile_controller.local_to_map(_tile_controller.get_local_mouse_position())
		selected_tower.position = _tile_controller.map_to_local(pos)
		selected_tower.update(false)
		if _tile_controller._can_place_tower(pos):
			selected_tower.set_display_valid()
		else:
			selected_tower.set_display_invalid()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if is_placing:
			money_requested.emit(selected_tower.cost, false, func(success: bool):
				if not success: return

				var pos: Vector2i = _tile_controller.local_to_map(_tile_controller.get_local_mouse_position())
				if _tile_controller.place_tower(pos, selected_tower):
					money_requested.emit(selected_tower.cost, true, func(success: bool):)
					tower_placed.emit(selected_tower)
					selected_tower.tower_clicked.connect(_select_tower)
					_select_tower(selected_tower)
					is_placing = false
					_tower_menu.open()
			)
			return
		if _upgrade_menu.is_open:
			_clear_selection()
		if _tower_menu.is_open:
			_tower_menu.close()

	if event.is_action_pressed("sell"):
		if _upgrade_menu.is_open:
			_upgrade_menu.close()
			selected_tower.queue_free()


func cancel_tower_placement() -> void:
	if is_placing:
		is_placing = false
		selected_tower.queue_free()


func _on_tower_button_pressed(tower_scene: PackedScene) -> void:
	if is_placing: return

	_tower_menu.close()
	_clear_selection()
	selected_tower = tower_scene.instantiate()
	_tile_controller.add_child(selected_tower, true)
	is_placing = true


func _on_tower_menu_button_pressed() -> void:
	_tower_menu.toggle_visibility()


func _select_tower(tower: Tower) -> void:
	if is_placing: return

	if _upgrade_menu.is_open and selected_tower == tower:
		_clear_selection()
	else:
		if selected_tower != tower:
			_clear_selection()

		selected_tower = tower
		selected_tower.select()
		_upgrade_menu.update_tower(tower)
		_upgrade_menu.open()


func _clear_selection() -> void:
	if selected_tower and selected_tower.selected:
		selected_tower.deselect()

	if _upgrade_menu.is_open:
		_upgrade_menu.close()
