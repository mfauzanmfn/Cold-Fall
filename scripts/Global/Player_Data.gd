extends Node

var typo_shield: bool = true
var money: int = 500
var booster_available: bool = true
var is_new_game: bool = true
var cart_lvl: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
