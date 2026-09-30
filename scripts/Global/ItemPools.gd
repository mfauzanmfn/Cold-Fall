extends Node


#var orders_pool: Dictionary = {
	#"Basic" : [
		#{"text": "BAKWAN", "price": 100},
		#{"text": "TAHU", "price": 200},
		#{"text": "CIRENG", "price": 300}
	#],
	#"Medium" : [
		#{"text": "INI TEXT MEDIUM", "price": 400}
	#]
#}
#
#var unlocked_groups: Array[String] = ["Basic"]

var orders_pool: Dictionary = {
	"Level1&2" : [
		{"text": "Kak! Satu cireng bumbu rujak", "price": 100},
		{"text": "Dua cireng original digoreng kering ya, Mbak", "price": 100},
		{"text": "Mau tiga cireng, tapi bumbunya tolong dipisah", "price": 100},
		{"text": "Beli cirengnya lima biji nggak pakai bumbu. Jangan lama, ya", "price": 100},
		{"text": "Kak, pesan cireng isi ayam suwir dua porsi", "price": 100},
		{"text": "Cireng bumbu kacang satu, tapi bumbunya jangan terlalu banyak", "price": 100},
		{"text": "Mbak, cireng merconnya tiga. Digoreng dadakan aja, ya!", "price": 100},
		{"text": "Neng cantik! Cireng rujak 4, yang 2 pedas, yang 2 lagi manis. Pisah plastiknya", "price": 100},
		{"text": "Permisi, mau beli cireng original sepuluh biji. Tolong gorengnya agak garing, ya, Kak", "price": 100},
		{"text": "Mbak, cireng kuah seblaknya satu! Kuahnya dibanyakin, nggak pake daun bawang, terus cirengnya setengah mateng aja", "price": 100}
	],
	"Medium" : [
		{"text": "INI TEXT MEDIUM", "price": 200}
	]
}

var unlocked_groups: Array[String] = ["Level1&2"]

func get_unlocked_items() -> Array:
	var items_array = []
	for group in unlocked_groups:
		items_array.append_array(orders_pool[group])
	return items_array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
