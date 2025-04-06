class_name GUIRoot
extends Control

signal tower_placed(tower: Tower)

const TOWER_SELECTOR_CLOSED_TOP: float = 100.0

var _tower_selector_pos_open: UIPosition = UIPosition.new()
var _tower_selector_pos_closed: UIPosition = UIPosition.new()

var selected_tower: Tower

var is_placing: bool = false
var is_selecting: bool = false
var is_tower_selector_open: bool = false

@onready var _tower_selector: TabContainer = $TowerSelector
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)
@onready var _top_bar: HBoxContainer = $TopBar
@onready var lives_display: ResourceDisplay = _top_bar.get_node("LivesDisplay")
@onready var money_display: ResourceDisplay = _top_bar.get_node("MoneyDisplay")

func _ready() -> void:
	var tower_buttons: Array[Node] = get_tree().get_nodes_in_group("tower_buttons")
	for button: TowerButton in tower_buttons:
		button.tower_button_pressed.connect(_on_tower_button_pressed)

	_tower_selector_pos_open.update_position(_tower_selector)
	_tower_selector_pos_closed.update_position(_tower_selector)
	_tower_selector_pos_closed.position.y = 100.0

	_tower_selector_pos_closed.set_node_position(_tower_selector)


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
		if is_placing:
			var pos: Vector2i = _tile_controller.local_to_map(_tile_controller.get_local_mouse_position())
			if _tile_controller.place_tower(pos, selected_tower):
				tower_placed.emit(selected_tower)
				selected_tower.tower_clicked.connect(_select_tower)
				is_placing = false
				toggle_tower_selector_visibility()
		elif is_selecting:
			_clear_selection()


func cancel_tower_placement() -> void:
	if is_placing:
		is_placing = false
		selected_tower.queue_free()


func toggle_tower_selector_visibility() -> void:
	if is_tower_selector_open:
		_tower_selector_pos_closed.tween_node_position(
			_tower_selector,
			0.15,
			Tween.EASE_IN,
			Tween.TRANS_CUBIC
		)
		is_tower_selector_open = false
	else:
		cancel_tower_placement()
		_tower_selector_pos_open.tween_node_position(
			_tower_selector,
			0.25,
			Tween.EASE_IN_OUT,
			Tween.TRANS_CUBIC
		)
		is_tower_selector_open = true


func _on_tower_button_pressed(tower_scene: PackedScene) -> void:
	toggle_tower_selector_visibility()
	selected_tower = tower_scene.instantiate()
	add_sibling(selected_tower)
	is_placing = true


func _select_tower(tower: Tower) -> void:
	if is_selecting:
		_clear_selection()

	is_selecting = true
	selected_tower.select()
	selected_tower = tower


func _clear_selection() -> void:
	if selected_tower.selected:
		selected_tower.deselect()
	is_selecting = false
