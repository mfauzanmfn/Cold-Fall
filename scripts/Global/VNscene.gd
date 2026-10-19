extends Node

var file_cerita_aktif : String = "res://assets/dialog_VN/epilogue.json"

func prologue() -> void:
	file_cerita_aktif = "res://assets/dialog_VN/prologue.json"
	get_tree().change_scene_to_file("res://scenes/VN.tscn")

func epilogue() -> void:
	file_cerita_aktif = "res://assets/dialog_VN/epilogue.json"
	get_tree().change_scene_to_file("res://scenes/VN.tscn")
