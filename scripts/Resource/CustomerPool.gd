extends RefCounted


const cust_pool = [
	{"normal": preload("res://assets/char/NPC/Andre/andre-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Andre/andre-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Hafsah/hafsah-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Hafsah/hafsah-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Khadavi/khadavi-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Khadavi/khadavi-dissapointed-expression.png")},
	{"normal": preload("res://assets/char/NPC/Milea/milea-normal-expression.png"),"dissapointed": preload("res://assets/char/NPC/Milea/milea-dissapointed-expression.png")}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
