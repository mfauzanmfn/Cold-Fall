extends Control

@onready var non_stick_pan: Button = $"HBoxContainer/Non-Stick Pan"
@onready var ayam_geprek_recipe: Button = $"HBoxContainer/Ayam Geprek Recipe"
@onready var dim_overlay: ColorRect = $DimOverlay
@onready var panel_container: PanelContainer = $PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_all_buttons(self)


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
	click_player.stream = load(SoundLibrary.button_click)
	add_child(click_player)
	click_player.play()
	click_player.finished.connect(click_player.queue_free)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		dim_overlay.visible = !dim_overlay.visible
		panel_container.visible = !panel_container.visible

func _on_non_stick_pan_pressed() -> void:
	Player_Data.typo_shield == true


func _on_ayam_geprek_recipe_pressed() -> void:
	if not OrdersPool.unlocked_groups.has("Ayam"):
		OrdersPool.unlocked_groups.append("Ayam")
	print("Unlocked: ", OrdersPool.unlocked_groups)

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/typing_scene.tscn")


func _on_button_pressed() -> void:
	SaveManager.save_game()
