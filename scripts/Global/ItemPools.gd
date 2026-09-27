extends Node

#test git
var item_pool: Dictionary = {
	"Basic" : [
		{"text": "BAKWAN", "price": 100},
		{"text": "TAHU", "price": 200},
		{"text": "CIRENG", "price": 300}
	],
	"Medium" : [
		{"text": "INI TEXT MEDIUM", "price": 400}
	]
}

var unlocked_groups: Array[String] = ["Basic"]

func get_unlocked_items() -> Array:
	var items_array = []
	for group in unlocked_groups:
		items_array.append_array(item_pool[group])
	return items_array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
