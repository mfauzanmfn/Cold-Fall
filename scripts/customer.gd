extends Panel

@onready var prompt: String
@onready var char_texture: TextureRect = $CenterContainer/Char_texture
@onready var char_container: CenterContainer = $CenterContainer

var current_letter_index: int = 0

@export var blue = Color('#4682b4')
@export var green = Color('#639765')
@export var red = Color('#a65455')

var normal: CompressedTexture2D
var dissapointed: CompressedTexture2D

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $CenterContainer/Char_texture/ProgressBar

@onready var success_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/SuccessEffect
@onready var fail_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/FailEffect

var order_price: int
var typo_checkpoint: int = 0

signal selected
signal exited


func get_prompt() -> String:
	return prompt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress_bar.value = 100 * (timer.wait_time - timer.time_left)/timer.wait_time
	if timer.time_left < (timer.wait_time * 0.5):
		char_texture.texture = dissapointed


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
