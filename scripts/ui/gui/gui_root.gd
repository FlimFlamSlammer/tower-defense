class_name GUIRoot
extends Control

signal money_requested(amount: int, spend: bool, cb: Callable)
signal tower_placed(tower: Tower)
signal wall_placed(wall: Wall)

const MENU_CLOSED_OFFSET: float = 100.0

var selected_tower: Tower
var selected_wall: Wall

var is_placing: bool = false
var placing_previous_position: Vector2i

var is_selecting: bool = false
var is_tower_selector_open: bool = false

@onready var _tower_menu: ClosableMenu = $TowerMenu
@onready var _upgrade_menu: UpgradeMenu = $UpgradeMenu
@onready var _wall_select_menu: WallSelectMenu = $WallSelectMenu
@onready var _tile_controller: TileController = Globals.get_tile_controller(get_tree())
@onready var _top_bar: HBoxContainer = $TopBar

@onready var lives_display: ResourceDisplay = _top_bar.get_node("LivesDisplay")
@onready var money_display: ResourceDisplay = _top_bar.get_node("MoneyDisplay")
@onready var wave_display: Label = %Wave

func _ready() -> void:
	var tower_buttons: Array[Node] = get_tree().get_nodes_in_group("tower_buttons")
	for button: TowerButton in tower_buttons:
		button.tower_button_pressed.connect(_on_tower_button_pressed)

	var wall_buttons: Array[Node] = get_tree().get_nodes_in_group("wall_buttons")
	for button: WallButton in wall_buttons:
		button.wall_button_pressed.connect(_on_wall_button_pressed)

	_tower_menu.closed_position.position.y = MENU_CLOSED_OFFSET
	_tower_menu.close(true)
	_tower_menu.on_open = func() -> void:
		cancel_tower_placement()
		cancel_wall_placement()

	_upgrade_menu.closed_position.position_inverted.x = - MENU_CLOSED_OFFSET
	_upgrade_menu.close(true)

	_wall_select_menu.closed_position.position_inverted.x = - MENU_CLOSED_OFFSET
	_wall_select_menu.close(true)


func _process(_delta: float) -> void:
	if is_placing:
		if selected_tower:
			var pos: Vector2i = _tile_controller.tile_map.local_to_map(_tile_controller.get_local_mouse_position())

			if pos != placing_previous_position:
				placing_previous_position = pos

				selected_tower.tile_position = pos

				_tile_controller.update_support_towers()
				selected_tower.update_status_effects()
				if _tile_controller.can_place_tower(pos):
					selected_tower.set_display_valid()
				else:
					selected_tower.set_display_invalid()
		elif selected_wall:
			var wall_map_pos: Vector2i = _tile_controller.wall_tile_map.local_to_map(_tile_controller.get_local_mouse_position())

			if wall_map_pos != placing_previous_position:
				placing_previous_position = wall_map_pos

				var pos: Dictionary[StringName, Variant] = _tile_controller.get_wall_pos_from_mouse()

				selected_wall.tile_position = pos.pos
				selected_wall.vertical = pos.vertical

				if _tile_controller.can_place_wall(pos.pos, pos.vertical):
					selected_wall.set_display_valid()
				else:
					selected_wall.set_display_invalid()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if is_placing:
			if selected_tower:
				_place_selected_tower()
			elif selected_wall:
				_place_selected_wall()
		else:
			if _upgrade_menu.is_open or _wall_select_menu.is_open:
				_clear_selection()
			if _tower_menu.is_open:
				_tower_menu.close()

	elif event.is_action_pressed("sell"):
		if _upgrade_menu.is_open:
			selected_tower.sell()
		elif _wall_select_menu.is_open:
			selected_wall.sell()


func load() -> void:
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")

	for tower: Tower in towers:
		tower.clicked.connect(_select_tower.bind(tower))
		tower.sold.connect(_upgrade_menu.close)

	var walls: Array[Node] = get_tree().get_nodes_in_group("walls")

	for wall: Wall in walls:
		wall.clicked.connect(_select_wall.bind(wall))
		wall.sold.connect(_wall_select_menu.close)


func cancel_tower_placement() -> void:
	if is_placing and selected_tower:
		is_placing = false
		selected_tower.queue_free()


func cancel_wall_placement() -> void:
	if is_placing and selected_wall:
		is_placing = false
		selected_wall.queue_free()


func _place_selected_tower() -> void:
	money_requested.emit(selected_tower.cost, false, func(success: bool) -> void:
		if not success: return

		if _tile_controller.place_tower(placing_previous_position, selected_tower):
			money_requested.emit(selected_tower.cost, true, Utils.null_callable)
			tower_placed.emit(selected_tower)

			selected_tower.clicked.connect(_select_tower.bind(selected_tower))
			selected_tower.sold.connect(_upgrade_menu.close)

			is_placing = false
			_select_tower(selected_tower)
			_tower_menu.open()
	)


func _place_selected_wall() -> void:
	money_requested.emit(selected_wall.cost, false, func(success: bool) -> void:
		if not success: return

		var pos: Dictionary[StringName, Variant] = _tile_controller.get_wall_pos_from_mouse()

		if _tile_controller.place_wall(pos.pos, pos.vertical, selected_wall):
			money_requested.emit(selected_wall.cost, true, Utils.null_callable)
			wall_placed.emit(selected_wall)

			selected_wall.clicked.connect(_select_wall.bind(selected_wall))
			selected_wall.sold.connect(_wall_select_menu.close)

			is_placing = false
			_tower_menu.open()
	)


func _on_tower_button_pressed(tower_scene: PackedScene) -> void:
	if is_placing: return

	_tower_menu.close()
	_clear_selection()
	selected_tower = tower_scene.instantiate()
	selected_tower.tile_controller = _tile_controller
	_tile_controller.add_child(selected_tower, true)
	is_placing = true
	placing_previous_position = Vector2i(-999, -999)


func _on_wall_button_pressed(wall_scene: PackedScene) -> void:
	if is_placing: return

	_tower_menu.close()
	_clear_selection()
	selected_wall = wall_scene.instantiate()
	selected_wall.tile_map = _tile_controller.wall_tile_map
	_tile_controller.add_child(selected_wall, true)
	is_placing = true
	placing_previous_position = Vector2i(-999, -999)


func _on_tower_menu_button_pressed() -> void:
	_tower_menu.toggle_visibility()


func _select_tower(tower: Tower) -> void:
	if is_placing: return

	if _upgrade_menu.is_open and selected_tower == tower:
		_clear_selection()
	else:
		if _upgrade_menu.is_open or _wall_select_menu.is_open: _clear_selection()
		selected_tower = tower
		selected_tower.select()
		_upgrade_menu.update_tower(tower)
		_upgrade_menu.open()


func _select_wall(wall: Wall) -> void:
	if is_placing: return

	if _wall_select_menu.is_open and selected_wall == wall:
		_clear_selection()
	else:
		if _upgrade_menu.is_open or _wall_select_menu.is_open: _clear_selection()
		selected_wall = wall
		selected_wall.select()
		_wall_select_menu.update_wall(wall)
		_wall_select_menu.open()


func _clear_selection() -> void:
	if selected_tower:
		selected_tower.deselect()
		selected_tower = null

	if selected_wall:
		selected_wall.deselect()
		selected_wall = null

	if _upgrade_menu.is_open:
		_upgrade_menu.close()

	if _wall_select_menu.is_open:
		_wall_select_menu.close()
