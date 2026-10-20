extends RefCounted

class_name VNChar

var attr_address : int
var attr_parent : Scripted
var attr_name : String
var attr_color : Color
var attr_texture : CompressedTexture2D
var attr_expression : Dictionary = {}

func _init(address : int, parent : Scripted) -> void:
	self.attr_address = address
	self.attr_parent = parent

func color(color : Color) -> VNChar:
	self.attr_color = color
	return self

func says(text : String, express : String = "") -> VNChar:
	assert(self.attr_parent != null)
	if express != "":
			self.emotion(express)
	self.attr_parent.says(text, self.attr_address)
	#_parent.register(VNTree.DialogText.new(_address, text))
	return self

func name(name : String) -> VNChar:
	self.attr_name = name
	
	if VNtexture.pools.has(name):
		attr_expression = VNtexture.pools[name].duplicate()	
		if attr_expression.has("normal"):
			self.attr_texture = attr_expression["normal"]
	return self

func texture(texture: String) -> VNChar:
	if texture != "":
		self.attr_texture = VNtexture.pools[self.attr_name][texture]
	return self
	
func add_emotion(emotion_name : String, texture_path : String) -> VNChar:
	attr_expression[emotion_name] = VNtexture.pools[self.attr_name][texture_path]
	return self

func emotion(emotion_name : String) -> VNChar:
	assert(self.attr_parent != null)
	
	self.attr_parent.jump(func():
		if attr_expression.has(emotion_name):
			attr_texture = attr_expression[emotion_name]
	)
	return self
