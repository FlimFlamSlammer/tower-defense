class_name UpgradeMenu
extends ClosableMenu

const MAX_TIER: int = 4
const MAX_TIER_CROSSPATH: int = 2

var _selected_tower: Tower

@onready var _upgrade_paths: Array[Node] = %UpgradePaths.get_children()
@onready var _tower_label: Label = %TowerLabel
@onready var _targeting_selector: Carousel = %TargetingSelector
@onready var _sell_button: Button = %SellButton
@onready var _sell_price_label: Label = %SellLabel


func close(instant: bool = false) -> void:
	_disconnect_previous_tower()
	super (instant)


func update_tower(tower: Tower) -> void:
	_disconnect_previous_tower()
	_selected_tower = tower

	_tower_label.text = _selected_tower.tower_name

	for i in _upgrade_paths.size():
		var upgrade_path: UpgradePath = _upgrade_paths[i]
		upgrade_path.button_pressed.connect(tower.upgrade_tower.bind(i))

	tower.modified.connect(_update)

	_targeting_selector.option_changed.connect(func(val: int) -> void:
		_selected_tower.targeting = _selected_tower.targeting_options[val]
	)

	_sell_button.pressed.connect(_selected_tower.sell)

	_update()


func _update() -> void:
	var highest_tier: int = _selected_tower.current_upgrade.max()
	var lock_other_paths: bool = highest_tier > MAX_TIER_CROSSPATH

	if _selected_tower.targeting_options.is_empty():
		_targeting_selector.hide()
	else:
		_targeting_selector.show()
		_targeting_selector.set_options(_selected_tower.targeting_options)
		_targeting_selector.set_option(_selected_tower.targeting_options.find(_selected_tower.targeting))

	for i in _selected_tower.current_upgrade.size():
		var upgrade_path: UpgradePath = _upgrade_paths[i]
		var tier: int = _selected_tower.current_upgrade[i]

		if lock_other_paths and tier == MAX_TIER_CROSSPATH or tier == MAX_TIER:
			upgrade_path.disabled = true
			upgrade_path.upgrade_name = _selected_tower.upgrades.get_upgrade(i, tier).name
		else:
			upgrade_path.disabled = false
			upgrade_path.upgrade_name = _selected_tower.upgrades.get_upgrade(i, tier + 1).name
			upgrade_path.cost = _selected_tower.upgrades.get_upgrade(i, tier + 1).cost
			upgrade_path.description = _selected_tower.upgrades.get_upgrade(i, tier + 1).description

		upgrade_path.tier = tier

	_sell_price_label.text = str(_selected_tower.get_sell_value())


func _disconnect_previous_tower() -> void:
	if _selected_tower and _selected_tower.modified.is_connected(_update):
		for i in _upgrade_paths.size():
			var upgrade_path: UpgradePath = _upgrade_paths[i]
			upgrade_path.button_pressed.disconnect(_selected_tower.upgrade_tower)

		_selected_tower.modified.disconnect(_update)
		_sell_button.pressed.disconnect(_selected_tower.sell)
