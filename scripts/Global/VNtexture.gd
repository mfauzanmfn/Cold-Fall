extends Node

var pools : Dictionary = {
	"char_a": {
		"normal" : preload("res://assets/eye open/3_normal.png"),
		"talk" : preload("res://assets/eye open/3_talk.png"),
		"smile": preload("res://assets/eye closed ^_^/3_smile.png"),
		"slmad" : preload("res://assets/eye closed ^_^/3_slight mad.png"),
		"cry" : preload("res://assets/eye closed u_u/3_cry.png")
	},
	"MC": {
		"normal" : preload("res://assets/Gita Marani (MC)/mc-normal-expression.png"),
		"awkward" : preload("res://assets/Gita Marani (MC)/mc-awkward-expression.png"),
		"curious": preload("res://assets/Gita Marani (MC)/mc-curious-expression.png"),
		"angry" : preload("res://assets/Gita Marani (MC)/mc-angry-expression.png"),
		"crying" : preload("res://assets/Gita Marani (MC)/mc-crying-expression.png")
	}
}
