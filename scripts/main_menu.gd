extends Control

@onready var start_button: Button = $VBoxContainer/Start_button
@onready var setting_button: Button = $VBoxContainer/Setting_button
@onready var exit_button: Button = $VBoxContainer/Exit_button
@onready var continue_button: Button = $VBoxContainer/Continue_button
@onready var click_sound: AudioStreamPlayer = $click_sound
@onready var menu_bgm: AudioStreamPlayer = $Menu_bgm
@onready var setting_panel: Panel = $Setting_panel
@onready var volume_slider: HSlider = $Setting_panel/Volume_slider
@onready var close_button: Button = $Setting_panel/close_button

func _ready() -> void:
	menu_bgm.play()
	
	SaveManager.load_game()
	if !Player_Data.is_new_game:
		continue_button.visible = true
	setting_panel.visible = false
	start_button.toggled.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	click_sound.play()
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/VN.tscn")

func _on_exit_button_pressed() -> void:
	click_sound.play()
	get_tree().quit()

func _on_continue_button_pressed() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/upgrade_scene.tscn")

func _on_setting_button_pressed() -> void:
	click_sound.play()
	setting_panel.visible = true

func _on_close_button_pressed() -> void:
	click_sound.play()
	setting_panel.visible = false

func _on_volume_slider_value_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, value)
	if value <= -50.0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
