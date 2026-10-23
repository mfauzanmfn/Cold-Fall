extends RefCounted


const cust_pool = [
	{"normal": preload("res://assets/char/NPC/Andre/andre-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Andre/andre-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Hafsah/hafsah-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Hafsah/hafsah-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Khadavi/khadavi-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Khadavi/khadavi-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Milea/milea-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Milea/milea-dissapointed-expression.png")}
]

const cart_pool = [
	preload("res://assets/typing_assets/cart/cart-lvl-1.png"),
	preload("res://assets/typing_assets/cart/cart-lvl-2.png")
]

const stove = {
	"off" : preload("res://assets/typing_assets/stove/stove-off.png"),
	"on" : preload("res://assets/typing_assets/stove/stove-on.png")
}

const  wok = {
	"off" : preload("res://assets/typing_assets/wok/wok-off.png"),
	"on" : preload("res://assets/typing_assets/wok/wok-on.png") 
}

const PhaseLocation = {
	"PHS_00": preload("res://assets/environments/DarkAlley/dark-alley.png"),
	"PHS_01": preload("res://assets/environments/DarkAlley/dark-alley.png"),
	"PHS_02": preload("res://assets/environments/SmallAlley/small-alley.png"),
	"PHS_03": preload("res://assets/environments/Roundabout/roundabout.png")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
