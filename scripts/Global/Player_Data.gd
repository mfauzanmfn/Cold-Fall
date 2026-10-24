extends Node

var typo_shield: bool = false
var money: int = 0
var income: int = 0
var booster_available: bool = true
var is_tutorial: bool = true
var cart_lvl: int = 1
var upgrade_levels: Dictionary = {}
var current_phase: String = "PHS_00"

func get_upgrade_level(id: String) -> int:
	return upgrade_levels.get(id, 0)

func to_dict() -> Dictionary:
	var dict: Dictionary
	for variable in get_property_list():
		if (variable["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE):
			dict[variable["name"]] = get(variable["name"])
	return dict
	
func from_dict(data: Dictionary):
	for variable in get_property_list():
		if (variable["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE):
			if data.has(variable["name"]):
				set(variable["name"], data[variable["name"]])
				
func apply_upgrade(upgrade: UpgradeData):
	match upgrade.effect:
		UpgradeData.Effect.CART_LVL:
			cart_lvl += 1
		UpgradeData.Effect.TYPO_SHIELD:
			typo_shield = true
		UpgradeData.Effect.AYAM_GEPREK_RECIPE:
			if income > 1500:
				current_phase = "PHS_02"
			OrdersPool.unlocked_groups.append("Ayam")
	Player_Data.upgrade_levels[upgrade.id] = Player_Data.get_upgrade_level(upgrade.id) + 1

		
