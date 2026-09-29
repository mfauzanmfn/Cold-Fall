extends Node2D

var s := Scripted.new()
var e : VNChar
var c : VNChar
var expression_memory : Dictionary = {}
var char_a_muncul : bool = false
var instant_text : bool = false
var is_skipping : bool = false
var timer_skip : float = 0.0
var auto_forward : bool = false


@onready var text: RichTextLabel = $RichTextLabel
@onready var author: Label = $VBoxContainer/Label
@onready var author_texture: TextureRect = $TextureRect
@onready var author_texture2: TextureRect = $TextureRect2
@onready var history_panel: Panel = $Historypanel
@onready var history_label: RichTextLabel = $Historypanel/ScrollContainer/Historylabel
@onready var skip_button: Button = $SkipButton
@onready var auto_button: Button = $AutoButton

var history: String = ""
var text_history_noted: String = ""

func _ready() -> void:
	s.from = self
	c = s.character().name("MC").color(Color.RED).texture("normal")
	e = s.character().name("char_a").color(Color.GREEN).texture("")
	
	skip_button.pressed.connect(_on_skip_button_pressed)
	auto_button.pressed.connect(_on_auto_button_pressed)
	history_panel.visible = false
	s.hide()
	s.wait(1.0)
	naskah_json("res://naskah_test.json")
	naskah_json("res://naskah_test2.json")
	s.start()

func naskah_json(file_path: String) -> void:
	var file_teks = FileAccess.get_file_as_string(file_path)
	var data_naskah = JSON.parse_string(file_teks)
	
	for baris in data_naskah:
		var nama_char = baris["karakter"]
		var ekspresi_baru = baris["ekspresi"]
		var teks_dialog = baris["dialog"]
		
		if ekspresi_baru != "-" and ekspresi_baru != "":
			expression_memory[nama_char] = ekspresi_baru
		var ekspresi_aktif = expression_memory.get(nama_char, "normal")
		
		if nama_char == "MC":
			c.emotion(ekspresi_aktif).says(teks_dialog)
		elif nama_char == "char_a":
			e.emotion(ekspresi_aktif).says(teks_dialog)

func _process(delta: float) -> void:
	text.text = s.text_output
	text.modulate.a = s.opacity_output
	
	if s.vrat_output <= 0.1:
		instant_text = false
	
	if  instant_text == true:
		text.visible_ratio = 1.0
	else:
		text.visible_ratio = s.vrat_output
	
	var karakter_aktif = s.get_character()
	if karakter_aktif != null:
		author.text = karakter_aktif.attr_name
		author.modulate = karakter_aktif.attr_color
		
		if karakter_aktif.attr_name == "MC":
			author_texture.texture = karakter_aktif.attr_texture
		elif karakter_aktif.attr_name == "char_a":
			author_texture2.texture = karakter_aktif.attr_texture
			char_a_muncul = true
	else:
		author.text = ""
	
	if char_a_muncul == false:
		author_texture2.visible = false
	else:
		author_texture2.visible = true
	
	var names_in_history = ""
	if karakter_aktif != null:
		names_in_history = karakter_aktif.attr_name
	
	var text_history_new = s.text_output
	if text_history_new != "" and text_history_new != text_history_noted:
		text_history_noted = text_history_new	
		var format_log = "[b]" + names_in_history + "[/b]\n" + text_history_new + "\n\n"
		history += format_log
		history_label.append_text(format_log)
	
	
	
	if auto_forward == true and history_panel.visible == false:
		timer_skip += delta
		
		if timer_skip >= 2.0:
			timer_skip = 0.0
			instant_text = true
			s.confirm.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		history_panel.visible = !history_panel.visible
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")
	
	if event.is_action_pressed("ui_right"):
		auto_forward = !auto_forward

	if event.is_action_pressed("ui_accept"):
		if history_panel.visible == false:
			if instant_text == true or s.vrat_output >= 1.0:
				s.confirm.emit()
			else:
				instant_text = true

func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")

func _on_auto_button_pressed() -> void:
	auto_forward = !auto_forward
