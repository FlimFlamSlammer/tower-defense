class_name ScreenMenuLayer
extends CanvasLayer

signal pause_requested()
signal resume_requested()

const MAX_OPEN_SCREEN_MENUS = 64

const _ALERT_SCENE: PackedScene = preload("res://scenes/ui/screen_menus/alert/alert.tscn")

var menu_open: bool = false

var _menu_stack: Array[ScreenMenu]

@onready var _pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	Events.alert_requested.connect(_create_alert)

	var children: Array[Node] = get_children()
	for child: Node in children:
		var menu := child as ScreenMenu

		if not menu: continue

		menu.opened.connect(_push_menu.bind(menu))
		menu.closed.connect(_close_menu.bind(menu))


func _create_alert(text: String, options: Array, callables: Array) -> void:
	var alert: Alert = _ALERT_SCENE.instantiate()
	add_child(alert)

	alert.opened.connect(_push_menu.bind(alert))
	alert.closed.connect(_close_menu.bind(alert))

	alert.text = text

	for i: int in range(options.size()):
		alert.add_option(options[i], callables[i])

	alert.open()


func _input(event: InputEvent) -> void:
	if not menu_open:
		if event.is_action_pressed("pause"):
			_pause_menu.open()


func _push_menu(menu: ScreenMenu) -> void:
	menu.z_index = _get_menu_z_index(_menu_stack.size())
	_menu_stack.push_back(menu)

	set_deferred("menu_open", true)

	pause_requested.emit()


func _close_menu(menu: ScreenMenu = _menu_stack.back()) -> void:
	if (_menu_stack.is_empty()):
		return

	if _menu_stack.back() == menu:
		_menu_stack.resize(_menu_stack.size() - 1)
	else:
		var index: int = _menu_stack.find(menu)
		if index == -1: return

		_menu_stack.remove_at(index)
		for i: int in range(index, _menu_stack.size()):
			_menu_stack[i].z_index = _get_menu_z_index(i)

	if _menu_stack.is_empty():
		set_deferred("menu_open", false)
		resume_requested.emit()


func _get_menu_z_index(index: int) -> int:
	return index * RenderingServer.CANVAS_ITEM_Z_MAX / MAX_OPEN_SCREEN_MENUS
