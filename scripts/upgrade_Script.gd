extends Control

@onready var non_stick_pan: Button = $"HBoxContainer/Non-Stick Pan"
@onready var ayam_geprek_recipe: Button = $"HBoxContainer/Ayam Geprek Recipe"
@onready var dim_overlay: ColorRect = $DimOverlay
@onready var options_panel: PanelContainer = $OptionsPanel
@onready var click_sound = load(SoundLibrary.button_click)
@onready var money_label: Label = $MoneyLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player_Data.check_phase_condition()
	money_label.text = "Balance: " + str(Player_Data.money)
	options_panel.visible = false
	_connect_all_buttons(self)
	if Player_Data.is_tutorial:
		Player_Data.is_tutorial = false

func _connect_all_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is UpgradeButton:   
			child.pressed.connect(_play_click)
			child.purchased.connect(_update_balance)
		_connect_all_buttons(child) 
	

func _update_balance():
	money_label.text = "Balance: " + str(Player_Data.money)
	

func _play_click():
	var click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	add_child(click_player)
	click_player.pitch_scale = randf_range(0.9, 1.1)
	click_player.play()
	click_player.finished.connect(click_player.queue_free)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		dim_overlay.visible = !dim_overlay.visible
		options_panel.visible = !options_panel.visible
	if OS.is_debug_build():
		if Input.is_action_just_pressed("key_8"):
			Player_Data.money += 500
			Player_Data.income += 500
			_update_balance()

func _on_texture_button_pressed() -> void:
	if Player_Data.current_phase == "PHS_05":
		get_tree().change_scene_to_file("res://scenes/epilogue.tscn")
	else:
		get_tree().change_scene_to_file(SceneManager.SCENES["typing_scene"])
	


func _on_save_button_pressed() -> void:
	SaveManager.save_game()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(SceneManager.SCENES["main_menu"])
