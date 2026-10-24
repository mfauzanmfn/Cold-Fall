extends CanvasLayer

@onready var cust_container: HBoxContainer = $VBoxContainer/GridContainer/HBoxContainer
@onready var slot_1: Control = $VBoxContainer/GridContainer/SlotContainer/slot1
@onready var slot_2: Control = $VBoxContainer/GridContainer/SlotContainer/slot2
@onready var slot_3: Control = $VBoxContainer/GridContainer/SlotContainer/slot3
var MainParent
@onready var instruction_panel: PanelContainer = $instructionPanel
@onready var instruction: RichTextLabel = $instructionPanel/VBoxContainer/Instruction
@onready var button: Button = $instructionPanel/VBoxContainer/Button
@onready var vbox: VBoxContainer = $instructionPanel/VBoxContainer
@onready var click_sound = load(SoundLibrary.button_click)
var _steps: Array[Dictionary] = [
	{
		"text" : "Mari bantu Gita melayani pelanggan pertamanya. Di game ini, kamu memasak dengan cara mengetik teks pesanan pelanggan secepat dan setepat mungkin!", 
		"button" : "Start",
		"size" : Vector2(400, 300),
		"anchor": Control.PRESET_CENTER,
		"position" : Vector2(0, 0),
		"font_size" : 16,
		"button_visible": true,
		"pause" : true,
		"advance_on" : "button"
	},
	{
		"text" : "Patience Bar: Jangan membuat pelanggan terlalu lama menunggu! Bar di atas pelanggan menunjukkan waktu yang mereka miliki sebelum mereka kesal dan pergi tanpa memesan",
		"button" : "",
		"size" : Vector2(200, 250),
		"anchor": Control.PRESET_TOP_RIGHT,
		"position" : Vector2(-10, 10),
		"font_size" : 16,
		"button_visible": false,	
		"pause" : false,
		"advance_on" : "timer", "timer_duration" : 10
	},
	{
		"text" : "Wah! Ada 2 customer di waktu bersamaan, tapi sepertinya Customer kedua bar kesabarannya sudah sangat tipis. Mari layani pelanggan tersebut dengan memencet panah kanan",
		"button" : "Ok",
		"size" : Vector2(300, 200),
		"anchor": Control.PRESET_TOP_RIGHT,
		"position" : Vector2(-10, 10),
		"font_size" : 16,
		"button_visible": false,
		"pause" : true,
		"advance_on" : "switch_right"
	}
]
var tween:Tween
var _current_steps: int = -1
var _step_id: int = 0

func _start_tutorial():
	_current_steps = -1
	MainParent.set_state(MainParent.State.TUTORIAL_PAUSED)
	_show_next_step()
	
func _show_next_step():
	if tween:
		tween.kill()
	_current_steps += 1
	_step_id += 1
	instruction_panel.modulate = Color.WHITE
	var my_id = _step_id
	
	if _current_steps >= _steps.size():
		return
	
	var step = _steps[_current_steps]
	if step["pause"]:
		MainParent.set_state(MainParent.State.TUTORIAL_PAUSED)
	else:
		MainParent.set_state(MainParent.State.SELECTION)

	instruction.text = step["text"]
	instruction.add_theme_font_size_override("normal_font_size", step["font_size"])
	instruction.custom_maximum_size = step["size"] - Vector2(40, 0)
	instruction_panel.size = step["size"]
	instruction_panel.set_anchors_and_offsets_preset(step["anchor"])
	instruction_panel.position += step["position"]
	instruction_panel.visible = true
	button.visible = step["button_visible"]
	
	if button.visible:
		button.text = step["button"]
	
	if step["advance_on"] == "timer":
		await get_tree().create_timer(step["timer_duration"]).timeout
		if my_id != _step_id:
			return
		tween = create_tween()
		tween.tween_property(instruction_panel, "modulate", Color(0), 2)
		await  tween.finished
		if my_id != _step_id:
			return
		
		instruction_panel.visible = false
		
func _advance_to_next():
	instruction_panel.visible = false
	_show_next_step()
	
func _on_button_pressed() -> void:
	var step = _steps[_current_steps]
	if step["advance_on"] != "button":
		return
	_advance_to_next()

func _unhandled_input(event: InputEvent) -> void:
	var step = _steps[_current_steps]
	var advance = step["advance_on"]
	if advance == "button" or advance == "timer":
		return
		
	if event.is_action_pressed(advance):
		get_viewport().set_input_as_handled()
		MainParent.set_state(MainParent.State.SELECTION)
		MainParent._on_customer_switch(event)
		instruction_panel.visible = false

func _connect_all_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:   
			child.pressed.connect(_play_click)
		_connect_all_buttons(child) 

func _play_click():
	var click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	click_player.volume_db = -5
	add_child(click_player)
	click_player.pitch_scale = randf_range(0.9, 1.1)
	click_player.play()
	click_player.finished.connect(click_player.queue_free)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_all_buttons(self)
	MainParent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
