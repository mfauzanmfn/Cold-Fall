extends Panel

@onready var prompt: RichTextLabel = $CenterContainer/Char_texture/order
@onready var prompt_text = prompt.text
@onready var pointer: TextureRect = $CenterContainer/Char_texture/pointer
@onready var char_texture: TextureButton = $CenterContainer/Char_texture

var current_letter_index: int = 0

@export var blue = Color('#4682b4')
@export var green = Color('#639765')
@export var red = Color('#a65455')

@onready var timer: Timer = $Timer
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

@onready var success_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/SuccessEffect
@onready var fail_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/FailEffect

var order_price: int

signal selected
signal exited

func set_pointer_visible(cond: bool):
	pointer.visible = cond

func get_prompt() -> String:
	return prompt_text

func set_next_character(next_character_index: int):
	var blue_text = ""
	if next_character_index > 0:
		blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0, next_character_index) + "[/color]"
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index, 1) + "[/color]"
	var red_text = ""
	if next_character_index != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index + 1, prompt_text.length()) + "[/color]"
	
	prompt.parse_bbcode("[center]" + blue_text + green_text + red_text + "[/center]")
	
func get_bbcode_color_tag(color: Color) -> String:	
	return "[color=#" + color.to_html(false) + "]"
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	char_texture.pressed.connect(_on_char_texture_pressed)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture_progress_bar.value = 100 * (timer.wait_time - timer.time_left)/timer.wait_time


func _on_char_texture_pressed() -> void:
	selected.emit(self)

func _on_timer_timeout() -> void:
	exited.emit(self)
