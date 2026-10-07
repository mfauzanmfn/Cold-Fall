extends Node

const CRG_ORI = 5
const CRG_KCG = 7
const CRG_ISI = 8
const AYM_ORI = 12
const AYM_KJU = 14
const AYM_MZR = 17

var orders_pool: Dictionary = {
	"Cireng" : {
		"Easy" : [
			{"text" : "Kak! Satu cireng bumbu kacang.", "price": CRG_KCG},
			{"text" : "Dua cireng original digoreng kering ya, Mbak.", "price": CRG_ORI * 2},
			{"text" : "Mau tiga cireng, tapi bumbunya tolong dipisah", "price": CRG_KCG * 3},
			{"text" : "Kak, pesan cireng isi ayam suwir dua porsi.", "price": CRG_ISI * 2},
			{"text" : "Cireng bumbu kacang satu, tapi bumbunya jangan terlalu banyak", "price": CRG_KCG},
			{"text" : "Mbak, cireng merconnya tiga. Digoreng dadakan aja, ya!", "price": CRG_ISI * 3},
		],
		"Hard" : [
			{"text": "Neng cantik! Cireng kacang 4, yang 2 pedas, yang 2 lagi manis. Pisah plastiknya.", "price": CRG_KCG * 4},
			{"text": "Permisi, mau beli cireng original sepuluh biji. Tolong gorengnya agak garing, ya, Kak.", "price": CRG_ORI * 10},
			{"text": "Mbak, cireng kuah seblaknya satu! Kuahnya dibanyakin, nggak pake daun bawang, terus cirengnya setengah mateng aja.", "price": CRG_ISI},
			{"text": "Beli cirengnya lima biji nggak pakai bumbu. Jangan lama, ya", "price": CRG_ORI * 5}
		]
	},
	"Ayam" : {
		"Easy" : [

			{"text" : "Ayam geprek level satu pakai nasi putih.", "price": AYM_ORI},
			{"text" : "Dua ayam geprek sambal bawang, nasinya setengah aja, Kak.", "price": AYM_ORI},
			{"text" : "Geprek dada mentok level tiga. Banyakkin kol goreng ya! Es teh manisnya jangan lupa!", "price": AYM_ORI}
		],
		"Hard" : [
			{"text": "Halo, pesan tiga Ayam Geprek Mozzarella! Level 5 semua, cabainya jangan diulek terlalu halus.", "price": AYM_MZR},
			{"text": "Paket ayam geprek paha atas satu. Tolong sambalnya dipisah, tambah tahu tempe, terus nasinya diganti mie goreng.", "price": AYM_ORI},
			{"text": "Permisi, Kak! Aku mau pesan 4 porsi ayam geprek. Dua level sepuluh, dua lagi level dewa. Oh iya, tambah sate usus 5 tusuk, ya", "price": AYM_ORI},
			{"text": "Mbak, pesanan super ribet nih! Ayam Geprek Keju dada mentok 2 porsi, level 15. Nasinya anget, ekstra kol goreng crispy, lalapannya dibanyakin, terus es teh tawar 2 gelas. Jangan sampai salah, ya!", "price": AYM_KJU}
		]
	}
}

var unlocked_groups: Array[String] = ["Cireng"]

func get_unlocked_items() -> Dictionary:
	var result = {}
	for menu in unlocked_groups:
		result[menu] = {}
		for difficulty in orders_pool[menu]:
			result[menu][difficulty] = orders_pool[menu][difficulty].duplicate(true)
	return result

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
