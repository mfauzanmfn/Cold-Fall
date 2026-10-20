class_name UpgradeData
extends Resource

enum Effect {CART_LVL, TYPO_SHIELD, AYAM_GEPREK_RECIPE}

@export var id: String
@export var price: int
@export var max_lvl: int
@export var effect: Effect
@export var is_consumable: bool
