class_name UpgradeButton
extends Button

@export var upgrade: UpgradeData
signal purchased
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if upgrade == null:
		return
	pressed.connect(_on_pressed)

func _on_pressed():
	if upgrade == null:
		return
	if Player_Data.get_upgrade_level(upgrade.id) >= upgrade.max_lvl:
		return
	if Player_Data.money < upgrade.price:
		return
	if upgrade.is_consumable and Player_Data.get_upgrade_level(upgrade.id) > 0:
		return
	Player_Data.money -= upgrade.price	
	purchased.emit()
	Player_Data.apply_upgrade(upgrade)
	if not upgrade.is_consumable:
		Player_Data.upgrade_levels[upgrade.id] = Player_Data.get_upgrade_level(upgrade.id) + 1
