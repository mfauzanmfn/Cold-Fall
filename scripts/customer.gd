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
@onready var patience_bar: TextureProgressBar = $CenterContainer/Char_texture/PatienceBar

@onready var success_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/SuccessEffect
@onready var fail_effect: GPUParticles2D = $CenterContainer/Char_texture/EffectsContainer/FailEffect

var order_price: int
var typo_checkpoint: int = 0
var long_wait: bool = false

signal selected
signal exited


func get_prompt() -> String:
	return prompt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Player_Data.cart_lvl > 1:
		timer.wait_time += 2
	patience_bar.value = 0
	_apply_state(false, false)
	timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	patience_bar.value = 100 * (timer.wait_time - timer.time_left)/timer.wait_time
	if timer.time_left < (timer.wait_time * 0.5) and not long_wait:
		long_wait = true
		char_texture.texture = dissapointed
		_flash_patience_bar()

func _apply_state(selected: bool, animate: bool):
	var target_scale = Vector2(1, 1) if selected else Vector2(0.9, 0.9)
	var target_modulate = Color.WHITE if selected else Color(0.7, 0.7, 0.7)

	if animate and is_inside_tree():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", target_scale, 0.5)
		tween.tween_property(self, "modulate", target_modulate, 0.5)
	else:
		scale = target_scale
		modulate = target_modulate
	
func _flash_patience_bar():
	var tween = create_tween().set_loops()
	tween.tween_property(patience_bar, "modulate", Color("d10055"), 0.4)
	tween.tween_property(patience_bar, "modulate", Color.WHITE, 0.4)
	
func _on_timer_timeout() -> void:
	exited.emit(self)

func become_unselected():
	_apply_state(false, true)
	
func become_selected():
	_apply_state(true, true)
