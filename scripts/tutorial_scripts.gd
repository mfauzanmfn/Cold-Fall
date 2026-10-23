extends Node

@onready var cust_container: HBoxContainer = $VBoxContainer/GridContainer/HBoxContainer
@onready var slot_1: Control = $VBoxContainer/GridContainer/SlotContainer/slot1
@onready var slot_2: Control = $VBoxContainer/GridContainer/SlotContainer/slot2
@onready var slot_3: Control = $VBoxContainer/GridContainer/SlotContainer/slot3
var MainParent
@onready var instruction_panel: PanelContainer = $instructionPanel
@onready var instruction: RichTextLabel = $instructionPanel/Instruction
@onready var button: Button = $instructionPanel/Button

var _steps: Array[Dictionary] = [
	{
		"text" : "Mari bantu Gita melayani pelanggan pertamanya. Di game ini, kamu memasak dengan cara mengetik teks pesanan di atas kepala pelanggan secepat dan setepat mungkin!", 
		"button" : "Start"
	},
	{
		"text" : "(Patience Bar: Jangan membuat pelanggan terlalu lama menunggu! Bar di atas pelanggan menunjukkan waktu yang mereka miliki sebelum mereka kesal dan pergi tanpa memesan)",
		"button" : "Paham"	 
	},
	{
		"text" : "Wah! Ada 2 customer di waktu bersamaan, tapi sepertinya Customer 3 bar kesabarannya sudah sangat tipis. Mari layani pelanggan tersebut dengan memencet panah kanan",
		"button" : "Ok"
	},
	{
		"text" : "Tutorial selesai!",
		"button" : "Selesai"
	}
]

var _current_steps: int = -1

func _start_tutorial():
	_current_steps = -1
	MainParent.set_state(MainParent.State.TUTORIAL_PAUSED)
	_show_next_step()
	
func _show_next_step():
	_current_steps += 1
	if _current_steps >= _steps.size():
		_end_tutorial()
		return
	
	var step = _steps[_current_steps]
	instruction.text = step["text"]
	button.text = step["button"]

	instruction_panel.visible = true
	
func _on_button_pressed() -> void:
	if MainParent.current_state == MainParent.State.TUTORIAL_PAUSED:
		MainParent.set_state(MainParent.State.SELECTION)
	instruction_panel.visible = false
	_show_next_step()

func _end_tutorial():
	get_tree().change_scene_to_file("res://scenes/upgrade_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainParent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
