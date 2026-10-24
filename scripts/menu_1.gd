extends Control

@onready var click_sound : AudioStreamPlayer = $click_sound
@onready var menu_bgm : AudioStreamPlayer = $menu_bgm

func _ready() -> void:
	menu_bgm.play()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		click_sound.play()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
