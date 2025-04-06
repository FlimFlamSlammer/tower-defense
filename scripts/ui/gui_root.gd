class_name GUIRoot
extends Control

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
	_tower_menu.on_open = cancel_tower_placement

	_upgrade_menu.closed_position.position_inverted.x = - MENU_CLOSED_OFFSET


func _process(_delta: float) -> void:
	if is_placing:
		var pos: Vector2i = _tile_controller.local_to_map(_tile_controller.get_local_mouse_position())
		selected_tower.position = _tile_controller.map_to_local(pos)
		selected_tower.modify_tower(false)
		if _tile_controller._can_place_tower(pos):
			selected_tower.set_display_valid()
		else:
			selected_tower.set_display_invalid()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		print("input was unhandled!")
		if is_placing:
			var pos: Vector2i = _tile_controller.local_to_map(_tile_controller.get_local_mouse_position())
			if _tile_controller.place_tower(pos, selected_tower):
				tower_placed.emit(selected_tower)
				selected_tower.tower_clicked.connect(_select_tower)
				is_placing = false
				_tower_menu.toggle_visibility()
		elif _upgrade_menu.is_open:
			_clear_selection()


func cancel_tower_placement() -> void:
	if is_placing:
		is_placing = false
		selected_tower.queue_free()


func _on_tower_button_pressed(tower_scene: PackedScene) -> void:
	if is_placing:
		return

	_tower_menu.close()
	selected_tower = tower_scene.instantiate()
	add_sibling(selected_tower)
	is_placing = true


func _on_tower_menu_button_pressed() -> void:
	_tower_menu.toggle_visibility()


func _select_tower(tower: Tower) -> void:
	print("tower clicked!")
	if _upgrade_menu.is_open:
		_clear_selection()
	else:
		selected_tower.select()
		selected_tower = tower
		_upgrade_menu.open()


func _clear_selection() -> void:
	if selected_tower.selected:
		selected_tower.deselect()
		_upgrade_menu.close()
