extends Node

var file_cerita_aktif : String = "res://epilogue.json"

func prologue() -> void:
	file_cerita_aktif = "res://introduction_scene.json"
	get_tree().change_scene_to_file("res://scenes/VN.tscn")

func epilogue() -> void:
	file_cerita_aktif = "res://epilogue.json"
	get_tree().change_scene_to_file("res://scenes/VN.tscn")
