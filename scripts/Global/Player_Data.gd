extends Node

var typo_shield: bool = true
var money: int = 500
var booster_available: bool = true
var is_new_game: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func to_dict() -> Dictionary:
	return {
		"money": money,
		"typo_shield": typo_shield,
		"is_new_game": is_new_game
	}
	
func from_dict(data: Dictionary):
	money = data.get("money", 0)
	typo_shield = data.get("typo_shield", 0)
	is_new_game = data.get("is_new_game", 0)
