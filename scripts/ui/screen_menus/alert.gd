class_name Alert
extends ScreenMenu

const _ALERT_BUTTON: PackedScene = preload("res://scenes/ui/screen_menus/alert/alert_button.tscn")

var text: String:
	set(val):
		text = val
		_label.text = val

@onready var _label: Label = %Label
@onready var _options: Node = %Options

func add_option(option_text: String, on_pressed: Callable) -> void:
	var new_button: Button = _ALERT_BUTTON.instantiate()
	_options.add_child(new_button)

	new_button.name = option_text
	new_button.text = option_text
	new_button.pressed.connect(func() -> void:
		on_pressed.call()
		close()
		queue_free()
	)


func remove_option(option_text: String) -> void:
	_options.get_node(option_text).queue_free()
