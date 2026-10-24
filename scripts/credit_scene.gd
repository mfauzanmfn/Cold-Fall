extends Control

@onready var credit_text: RichTextLabel = $Label
@onready var menu_button: Button = $Button
@onready var fade: ColorRect = $ColorRect2
@onready var ending_song: AudioStreamPlayer = $ending_song

func _ready() -> void:
	ending_song.play()
	menu_button.visible = false
	
	fade.visible = true
	fade.modulate.a = 1.0 
	var tween_masuk = create_tween()
	tween_masuk.tween_property(fade, "modulate:a", 0.0, 1.5) 	
	
	await get_tree().create_timer(5.0).timeout
	munculkan_tombol()

func munculkan_tombol() -> void:
	menu_button.visible = true

func _on_button_pressed() -> void:
	fade.visible = true
	var tween_keluar = create_tween()
	tween_keluar.tween_property(fade, "modulate:a", 1.0, 1.0) 
	await tween_keluar.finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
