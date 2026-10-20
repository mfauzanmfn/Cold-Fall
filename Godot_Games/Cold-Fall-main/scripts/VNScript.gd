extends Node2D

var s := Scripted.new()
var c : VNChar
var expression_memory : Dictionary = {}
var char_a_muncul : bool = false
var instant_text : bool = false
var is_skipping : bool = false
var timer_skip : float = 0.0
var auto_forward : bool = false
var id_dialog : int = 0
var posisi_awal_ui : Vector2
var total_dialog : int = 0

@onready var all_ui_dialog: = $VBoxContainer
@onready var dialog_box: TextureRect = $VBoxContainer/dialog_box
@onready var nametag: TextureRect = $VBoxContainer/nametag
@onready var text: RichTextLabel = $VBoxContainer/text_dialog
@onready var nama_char: Label = $VBoxContainer/nama_char
@onready var author_texture: TextureRect = $TextureRect
@onready var author_texture2: TextureRect = $TextureRect2
@onready var history_panel: Panel = $Historypanel
@onready var history_label: RichTextLabel = $Historypanel/ScrollContainer/Historylabel
@onready var skip_button: Button = $SkipButton
@onready var auto_button: Button = $AutoButton
@onready var history_button: Button = $HistoryButton
@onready var data_gita: TextureRect = $data_gita
@onready var BG_inflasi: TextureRect = $BG_inflasi
@onready var BG_polisi: TextureRect = $BG_polisi

var history: String = ""
var text_history_noted: String = ""

func _ready() -> void:
	s.from = self
	c = s.character().name("Gita").color(Color.RED).texture("normal")
	
	posisi_awal_ui = all_ui_dialog.position
	author_texture.texture = null
	
	skip_button.pressed.connect(_on_skip_button_pressed)
	auto_button.pressed.connect(_on_auto_button_pressed)
	history_panel.visible = false
	s.hide()
	s.wait(1.0)
	naskah_json(VNscene.file_cerita_aktif)
	s.start()

func naskah_json(file_path: String) -> void:
	var file_teks = FileAccess.get_file_as_string(file_path)
	var data_naskah = JSON.parse_string(file_teks)
	
	total_dialog = data_naskah.size()
	
	for baris in data_naskah:
		var nama_char = baris["karakter"]
		var ekspresi_baru = baris["ekspresi"]
		var teks_dialog = baris["dialog"]
		
		if ekspresi_baru != "-" and ekspresi_baru != "":
			expression_memory[nama_char] = ekspresi_baru
		var ekspresi_aktif = expression_memory.get(nama_char, "normal")
		
		if nama_char == "Gita":
			c.emotion(ekspresi_aktif).says(teks_dialog)
		else:
			s.character().name(nama_char).says(teks_dialog	)

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
		if karakter_aktif.attr_name == "Narrator" or karakter_aktif.attr_name == "Orang":
			nama_char.text = ""
		else:
			nama_char.text = karakter_aktif.attr_name
			nama_char.modulate = karakter_aktif.attr_color
		
		if karakter_aktif.attr_name == "Gita":
			author_texture.texture = karakter_aktif.attr_texture
	else:
		nama_char.text = ""

	var names_in_history = ""
	if karakter_aktif != null:
		names_in_history = karakter_aktif.attr_name
	
	var text_history_new = s.text_output
	if text_history_new != "" and text_history_new != text_history_noted:
		text_history_noted = text_history_new
		
		id_dialog += 1
		timer_skip = 0.0
		atur_koreografi_visual(id_dialog)
		
		var format_log = "[b]" + names_in_history + "[/b]\n" + text_history_new + "\n\n"
		history += format_log
		history_label.append_text(format_log)
	
	if auto_forward == true and not history_panel.visible:
		var teks_selesai: bool = (text.visible_ratio >= 1.0 or instant_text)
		
		if teks_selesai:
			timer_skip += delta
			if timer_skip >= 2.0:
				timer_skip = 0.0
				instant_text = true
				if id_dialog >= total_dialog:
					get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")
				else:
					s.confirm.emit()
		else:
			timer_skip = 0.0

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
				if id_dialog >= total_dialog:
					get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")
				else:
					s.confirm.emit()
			else:
				instant_text = true

func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")

func _on_auto_button_pressed() -> void:
	auto_forward = !auto_forward
	timer_skip = 0.0

func _on_history_button_pressed() -> void:
	history_panel.visible = !history_panel.visible

func atur_koreografi_visual(id: int) -> void:
	if VNscene.file_cerita_aktif.contains("epilogue"):
		koreografi_epilogue(id)
	else:
		koreografi_prologue(id)

func koreografi_prologue(id: int) -> void:
	match id:
		1:
			pass
		2:
			data_gita.visible = true
		3:
			if is_instance_valid(data_gita):
				data_gita.queue_free()
		4:
			author_texture.visible = false
		5:
			BG_inflasi.visible = true
			text.visible = false
			nama_char.visible = false
			all_ui_dialog.visible = false
		6:
			BG_inflasi.visible = false
			BG_polisi.visible = true
			all_ui_dialog.visible = true
			dialog_box.visible = false
			nametag.visible = false
			text.visible = true
			all_ui_dialog.position = Vector2(posisi_awal_ui.x, 250)
		7:
			BG_polisi.visible = false
			author_texture.visible = true
			dialog_box.visible = true
			nametag.visible = true
			nama_char.visible = true
			all_ui_dialog.position = posisi_awal_ui

func koreografi_epilogue(id: int) -> void:
	match id:
		1:
			author_texture.visible = true
		2:
			author_texture.visible = false
			dialog_box.visible = false
			nametag.visible = false
			all_ui_dialog.position = Vector2(450, 250)
		3:
			author_texture.visible = true
			dialog_box.visible = true
			nametag.visible = true
			author_texture.visible = false
			all_ui_dialog.position = posisi_awal_ui
