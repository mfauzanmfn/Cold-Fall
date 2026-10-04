extends Control

@onready var non_stick_pan: Button = $"HBoxContainer/Non-Stick Pan"
@onready var ayam_geprek_recipe: Button = $"HBoxContainer/Ayam Geprek Recipe"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_non_stick_pan_pressed() -> void:
	Player_Data.typo_shield == true


func _on_ayam_geprek_recipe_pressed() -> void:
	OrdersPool.unlocked_groups.append("Medium")


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")
