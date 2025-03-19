class_name GUIRoot
extends CanvasLayer

const TOWER_SELECTOR_POSITION := Vector2(832, 1856)
const TOWER_SELECTOR_HIDE_POSITION := Vector2(832, 2400)

var selected_tower: Tower

var is_placing: bool = false
var is_tower_selector_open: bool = false

@onready var _tower_selector: TabContainer = $TowerSelector
@onready var _tile_controller: TileController = get_node(Globals.TILE_CONTROLLER_PATH)

func _ready() -> void:
	var tower_buttons: Array[Node] = get_tree().get_nodes_in_group("tower_buttons")
	for button: TowerButton in tower_buttons:
		button.tower_button_pressed.connect(_on_tower_button_pressed)

	_tower_selector.position = TOWER_SELECTOR_HIDE_POSITION


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
				is_placing = false
				toggle_tower_selector_visibility()


func cancel_tower_placement() -> void:
	if is_placing:
		is_placing = false
		selected_tower.queue_free()


func toggle_tower_selector_visibility() -> void:
	var tween: Tween = create_tween()
	if is_tower_selector_open:
		tween.tween_property(_tower_selector, "position", TOWER_SELECTOR_HIDE_POSITION, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		is_tower_selector_open = false
	else:
		cancel_tower_placement()
		tween.tween_property(_tower_selector, "position", TOWER_SELECTOR_POSITION, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		is_tower_selector_open = true


func _on_tower_button_pressed(tower_scene: PackedScene) -> void:
	print(tower_scene)
	toggle_tower_selector_visibility()
	selected_tower = tower_scene.instantiate()
	add_sibling(selected_tower)
	is_placing = true
