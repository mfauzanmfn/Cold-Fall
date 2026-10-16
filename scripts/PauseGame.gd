extends PanelContainer

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
var MainParent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	MainParent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_pressed() -> void:
	MainParent.set_state(MainParent.State.SELECTION)


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
