extends Node2D

var s := Scripted.new()
var c : VNChar
var expression_memory : Dictionary = {}
var background_memory : Dictionary = {}
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
@onready var history_exit: Button = $Historypanel/HistoryExit
@onready var data_gita: TextureRect = $data_gita
@onready var BG: TextureRect = $BG
@onready var click_sound: AudioStreamPlayer = $click_sound
@onready var click_skips: AudioStreamPlayer = $click_skips
@onready var breath_sound: AudioStreamPlayer = $breath
@onready var glitch_sound: AudioStreamPlayer = $glitch
@onready var rain_sound: AudioStreamPlayer = $Heavyrain
@onready var ending_song: AudioStreamPlayer = $ending_game
@onready var layar_fade: ColorRect = $ColorRect

var history: String = ""
var text_history_noted: String = ""

func _ready() -> void:
	s.from = self
	c = s.character().name("Gita").color(Color.WHITE).texture("normal")
	
	posisi_awal_ui = all_ui_dialog.position
	author_texture.texture = null
	
	skip_button.pressed.connect(_on_skip_button_pressed)
	auto_button.pressed.connect(_on_auto_button_pressed)
	history_panel.visible = false
	s.hide()
	s.wait(1.0)
	naskah_json("res://assets/dialog_VN/epilogue.json")
	s.start()

func naskah_json(file_path: String) -> void:
	var file_teks = FileAccess.get_file_as_string(file_path)
	var data_naskah = JSON.parse_string(file_teks)
	
	total_dialog = data_naskah.size()
	
	var id_temp = 0
	
	for baris in data_naskah:
		id_temp += 1
		
		var nama_char = baris["karakter"]
		var ekspresi_baru = baris["ekspresi"]
		var teks_dialog = baris["dialog"]
		
		if baris.has("bg") and baris["bg"] != "":
			background_memory[id_temp] = baris["bg"]
		
		if ekspresi_baru != "-" and ekspresi_baru != "":
			expression_memory[nama_char] = ekspresi_baru
		var ekspresi_aktif = expression_memory.get(nama_char, "normal")
		
		if nama_char == "Gita":
			c.emotion(ekspresi_aktif).says(teks_dialog)
		else:
			s.character().name(nama_char).says(teks_dialog)

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
		
		if background_memory.has(id_dialog):
			ubah_background(background_memory[id_dialog])
		
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
					get_tree().change_scene_to_file("res://scenes/credit_scene.tscn")
				else:
					s.confirm.emit()
		else:
			timer_skip = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		history_panel.visible = !history_panel.visible
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/credit_scene.tscn")
	
	if event.is_action_pressed("ui_right"):
		auto_forward = !auto_forward

	if event.is_action_pressed("ui_accept"):
		if history_panel.visible == false:
			if instant_text == true or s.vrat_output >= 1.0:
				if id_dialog >= total_dialog:
					get_tree().change_scene_to_file("res://scenes/credit_scene.tscn")
				else:
					s.confirm.emit()
			else:
				instant_text = true

func _on_skip_button_pressed() -> void:
	click_skips.play()
	get_tree().change_scene_to_file("res://scenes/credit_scene.tscn")

func _on_auto_button_pressed() -> void:
	click_sound.play()
	auto_forward = !auto_forward
	timer_skip = 0.0

func _on_history_button_pressed() -> void:
	click_sound.play()
	history_panel.visible = !history_panel.visible

func _on_history_exit_pressed() -> void:
	click_sound.play()
	history_panel.visible = !history_panel.visible

func ubah_background(file_path: String) -> void:
	var bg_asset = load(file_path)
	if bg_asset != null:
		BG.texture = bg_asset
		BG.visible = true
	else:
		print("Error: Background gagal dimuat pada path -> ", file_path)

func efek_fade(durasi: float = 0.5) -> void:
	layar_fade.modulate.a = 1.0 
	layar_fade.visible = true
	var tween = create_tween()
	tween.tween_property(layar_fade, "modulate:a", 0.0, durasi)

func atur_koreografi_visual(id: int) -> void:
	koreografi_epilogue(id)

func koreografi_epilogue(id: int) -> void:
	match id:
		1:
			author_texture.visible = true
		2:
			glitch_sound.play()
			author_texture.visible = false
			dialog_box.visible = false
			nametag.visible = false
			all_ui_dialog.position = Vector2(450, 250)
		3:
			rain_sound.play()
			breath_sound.play()
			efek_fade(0.5)
			author_texture.visible = true
			dialog_box.visible = true
			nametag.visible = true
			author_texture.visible = false
			all_ui_dialog.position = posisi_awal_ui
		4:
			pass
		5:
			efek_fade(0.5)
			breath_sound.stop()
			rain_sound.stop()
			ending_song.play()
			author_texture.visible = false
			dialog_box.visible = false
			nametag.visible = false
			skip_button.visible = false
			auto_button.visible = false
			history_button.visible = false
			all_ui_dialog.position = Vector2(450, 250)

func credit_transition() -> void:
	layar_fade.visible = true
	var tween = create_tween()
	tween.tween_property(layar_fade, "modulate:a", 1.0, 1.5)
	await tween.finished 
	get_tree().change_scene_to_file("res://scenes/credit_scene.tscn")
