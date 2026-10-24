extends Control

@onready var non_stick_pan: Button = $"HBoxContainer/Non-Stick Pan"
@onready var ayam_geprek_recipe: Button = $"HBoxContainer/Ayam Geprek Recipe"
@onready var dim_overlay: ColorRect = $DimOverlay
@onready var options_panel: PanelContainer = $OptionsPanel
@onready var click_sound = load(SoundLibrary.button_click)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Player_Data.income > 4000:
		Player_Data.current_phase = "PHS_03"
	elif Player_Data.income > 9999:
		Player_Data.current_phase = "PHS_04"
	options_panel.visible = false
	_connect_all_buttons(self)
	if Player_Data.is_tutorial:
		Player_Data.is_tutorial = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _connect_all_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:   
			child.pressed.connect(_play_click)
		_connect_all_buttons(child) 

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

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file(SceneManager.SCENES["typing_scene"])
	


func _on_save_button_pressed() -> void:
	SaveManager.save_game()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
