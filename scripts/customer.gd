extends Panel

@onready var prompt: RichTextLabel = $CenterContainer/Char_texture/order
@onready var char_texture: TextureButton = $CenterContainer/Char_texture
@onready var char_container: CenterContainer = $CenterContainer

var current_letter_index: int = 0

@export var blue = Color('#4682b4')
@export var green = Color('#639765')
@export var red = Color('#a65455')

var normal: CompressedTexture2D
var dissapointed: CompressedTexture2D

@onready var timer: Timer = $Timer
@onready var texture_progress_bar: TextureProgressBar = $CenterContainer/Char_texture/TextureProgressBar

@onready var success_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/SuccessEffect
@onready var fail_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/FailEffect

var order_price: int

signal selected
signal exited


func get_prompt() -> String:
	prompt.parse_bbcode(prompt.text)
	return prompt.text

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

func become_unselected():
	var tween = get_tree().create_tween()
	tween.tween_property(char_container, "scale", Vector2(0.9, 0.9), 0.5)
	char_texture.modulate = Color(0.7, 0.7, 0.7)
	
func become_selected():
	var tween = get_tree().create_tween()
	tween.tween_property(char_container, "scale", Vector2(1, 1), 0.5)
	char_texture.modulate = Color(1, 1, 1)
