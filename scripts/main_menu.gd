extends Control

@onready var start_button: Button = $VBoxContainer/Start_button
@onready var setting_button: Button = $VBoxContainer/Setting_button
@onready var exit_button: Button = $VBoxContainer/Exit_button

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Test.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
