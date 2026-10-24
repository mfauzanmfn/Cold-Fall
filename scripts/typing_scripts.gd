extends Control

@onready var cust_container: HBoxContainer = $VBoxContainer/GridContainer/HBoxContainer
@onready var slot_1: Control = $VBoxContainer/GridContainer/SlotContainer/slot1
@onready var slot_2: Control = $VBoxContainer/GridContainer/SlotContainer/slot2
@onready var slot_3: Control = $VBoxContainer/GridContainer/SlotContainer/slot3
@onready var order_text: RichTextLabel = $OrderContainer/OrderText
@onready var backgrounds: TextureRect = $Backgrounds
@onready var result_container: PanelContainer = $ResultContainer

@onready var tutorial: CanvasLayer = $TutorialLayer

@onready var order_container: PanelContainer = $OrderContainer
@onready var pause_container: PanelContainer = $PauseContainer

@export var typed: Color
@export var current_character : Color
@export var remaining: Color
@export var typo_color: Color
@onready var typo_shield_marker: TextureRect = $PowerUpContainer/TypoShield_Marker
@onready var booster_marker: TextureRect = $PowerUpContainer/BoosterMarker

@onready var customer_progress_bar: TextureProgressBar = $OrderContainer/CustomerProgressBar
@onready var dim_overlay: ColorRect = $DimOverlay

@onready var frying_sfx: AudioStreamPlayer = $FryingSfx
@onready var typo_sfx: AudioStreamPlayer = $TypoSfx

enum State {PAUSED, SELECTION, SERVING, GAMEOVER, TUTORIAL_PAUSED} 
enum RemovalReason {SERVED, TIMED_OUT}	
var current_state: State = State.SELECTION

var angka: Dictionary = {
	"satu" : "1",
	"dua" : "2",
	"tiga" : "3",
	"empat" : "4",
	"lima" : "5",
	"enam" : "6",
	"tujuh" : "7",
	"delapan" : "8",
	"sembilan" : "9",
	"sepuluh" : "10"
}

@onready var slot_container: HBoxContainer = $VBoxContainer/GridContainer/SlotContainer
var slot_count

const CUST_PANEL = preload("uid://ba5t8skrj86ph")
@onready var timer_progress_ring: TextureProgressBar = $TimerProgressRing

const ResourceScript = preload("res://scripts/Resource/TypingResources.gd")
const CUSTOMER_POOL = ResourceScript.cust_pool

var item_pool 
var selected_customer
var unselected_customer_letter_index: int = 0
var served_customer: int = 0
var max_cust_count: int = 2
var curr_cust_count: int = 0
var combo: int = 0
var earnings: int = 0

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $Timer_Label
@onready var delay_timer: Timer = $DelayTimer

@onready var cart: TextureRect = $Cart
@onready var stove: TextureRect = $Cart/Stove
@onready var wok: TextureRect = $Cart/Stove/Wok
@onready var lamp: TextureRect = $Cart/Lamp
@onready var stove_timer: Timer = $StoveTimer
var tween: Tween
@onready var bgm: AudioStreamPlayer = $BGM

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backgrounds.texture = ResourceScript.PhaseLocation[Player_Data.current_phase]
	order_container.modulate = Color(0)
	item_pool = OrdersPool.get_unlocked_items()
	slot_count = slot_container.get_child_count() 
	
	cart.texture = ResourceScript.cart_pool[Player_Data.cart_lvl-1]
	lamp.texture = ResourceScript.lamp_pool[Player_Data.cart_lvl-1]
	
	stove_timer.timeout.connect(_turn_stove_off)
	if frying_sfx.stream != null:
		stove_timer.wait_time = frying_sfx.stream.get_length()
	frying_sfx.pitch_scale = randf_range(0.9, 1.1)
	typo_sfx.pitch_scale = randf_range(0.9, 1.1)
	typo_shield_marker.visible = Player_Data.typo_shield	

	if Player_Data.is_tutorial and get_node_or_null("TutorialLayer") != null:
		slot_1.add_child(create_random_customer())
		timer_label.visible = false
	else:
		fill_all_slot()
		timer_label.visible = true
		timer.start()
	selected_customer = slot_1.get_child(0)
	selected_customer.become_selected()
	order_text.text = selected_customer.prompt
	set_next_character(selected_customer.current_letter_index, false)
	bgm.volume_db = -30
	tween = create_tween()
	tween.tween_property(bgm, "volume_db", 0.0, 4)
	bgm.play()
	if Player_Data.is_tutorial:
		tutorial._start_tutorial()
		
func fill_all_slot():
	for slot in slot_container.get_children():
		if slot.get_child_count() == 0: 
			slot.add_child(create_random_customer())
		
func set_state(new_state: State):
	if current_state == new_state:
		return
	_exit_state(current_state)
	current_state = new_state
	_enter_state(new_state)
func _enter_state(state: State):
	match state:
		State.PAUSED:
			get_tree().paused = true
			pause_container.visible = true
			dim_overlay.visible = true
			dim_overlay.top_level = true
		State.SELECTION:
			pass
		State.SERVING:
			order_container.modulate = Color(1, 1, 1, 1)
			dim_overlay.visible = true
		State.TUTORIAL_PAUSED:
			dim_overlay.visible = true
			for slot in slot_container.get_children():
				if slot.get_child(0) != null:
					slot.get_child(0).timer.paused = true 
		State.GAMEOVER:
			for slot in slot_container.get_children():
				if slot.get_child_count() > 0:
					slot.get_child(0).queue_free()
			Player_Data.money += earnings
			Player_Data.income += earnings
			result_container._on_ui_visible()
						
func _exit_state(state: State):
	match state:
		State.PAUSED:
			get_tree().paused = false
			pause_container.visible = false
			dim_overlay.visible = false
			dim_overlay.top_level = false
		State.SELECTION:
			pass
		State.SERVING:
			frying_sfx.stop()
			order_container.modulate = Color(0)
			dim_overlay.visible = false
		State.TUTORIAL_PAUSED:
			dim_overlay.visible = false
			tutorial.instruction_panel.visible = false
			for slot in slot_container.get_children():
				if slot.get_child(0) != null:
					slot.get_child(0).timer.paused = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_label.text = "%d" % timer.time_left
	timer_progress_ring.value = 100 * (timer.wait_time - timer.time_left)/timer.wait_time
	if current_state != State.GAMEOVER:
		customer_progress_bar.value = selected_customer.patience_bar.value
	
func create_random_customer() -> Panel:
	var cust_entry_number: int = randi() % CUSTOMER_POOL.size()
	var cust_entry = CUSTOMER_POOL[cust_entry_number]
	
	var menus = item_pool.keys()
	
	var menu_name = menus[randi() % menus.size()]
	var menu_chosen = item_pool[menu_name]
	
	var difficulties = menu_chosen.keys()
	var weights = PackedFloat32Array([70.0, 30.0])
	var rng = RandomNumberGenerator.new()
	var difficulty_chosen = difficulties[rng.rand_weighted(weights)]
	
	var orders = menu_chosen[difficulty_chosen]
	var selected_order = orders[randi() % orders.size()]
	
	var panel = CUST_PANEL.instantiate()
	panel.selected.connect(_on_customer_switch)
	panel.exited.connect(_on_customer_exited)
	
	var customer_timer = panel.get_node("Timer")
	panel.set_meta("timer", customer_timer)
		
	
	var center = panel.get_child(0)
	var cust_texture = center.get_child(0)
	
	panel.normal = cust_entry.normal
	panel.dissapointed = cust_entry.dissapointed
	cust_texture.texture = panel.normal
	panel.prompt = selected_order.text
	panel.order_price = selected_order.price
	panel.become_unselected()
	
	return panel
		
func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if Input.is_action_just_pressed("key_6"):
			set_state(State.GAMEOVER)
		elif Input.is_action_just_pressed("key_7"):
			earnings += 500
	match current_state:
		State.GAMEOVER:
			return
		State.PAUSED:
			if event.is_action_pressed("ui_cancel"):
				set_state(State.SELECTION)
		State.SELECTION:
			if Input.is_action_just_pressed("ui_cancel"):
				set_state(State.PAUSED)
			elif Input.is_action_just_pressed("ui_accept") and delay_timer.is_stopped():
				set_state(State.SERVING)
			else:
				_on_customer_switch(event)
		State.SERVING:
			if event.is_action_pressed("ui_cancel"):
				set_state(State.SELECTION)
				return
			elif Input.is_action_just_pressed("arrow_up") and Player_Data.booster_available:
				order_text.text = booster_active(order_text.text, selected_customer.current_letter_index)
				set_next_character(selected_customer.current_letter_index, false)
				Player_Data.booster_available = false
				return
			_handle_typing_input(event)
		State.TUTORIAL_PAUSED:
			pass
		
func _handle_typing_input(event: InputEvent):
	if not delay_timer.is_stopped():
		return
	var typed_event = event.unicode
	if typed_event == 0:
		return
	var key_typed = char(typed_event).to_upper()
	var next_character = order_text.text[selected_customer.current_letter_index].to_upper()
	
	if key_typed == next_character:
		if frying_sfx.stream == null:
			frying_sfx.stream = load(SoundLibrary.frying[randi_range(0, 1)])
		frying_sfx.play()
		turn_stove_on()
		if selected_customer.timer.time_left < 5:
			selected_customer.order_price = selected_customer.order_price * (4/5)
		selected_customer.current_letter_index += 1
		set_next_character(selected_customer.current_letter_index, false)
		turn_stove_on()
		if selected_customer.current_letter_index == order_text.text.length():
			set_state(State.SELECTION)
			combo += 1
			if combo <= 2:
				earnings += selected_customer.order_price
			elif combo <= 5:
				earnings += selected_customer.order_price * 1.2
			else :
				earnings += selected_customer.order_price * 1.5
			
			var customer_timer = selected_customer.get_meta("timer")
			var finished_customer = selected_customer
			customer_timer.paused = true
			finished_customer._stop_patience_bar_flash()
			delay_timer.wait_time = 2
			delay_timer.start()
			await delay_timer.timeout
			_replace_customer(finished_customer, RemovalReason.SERVED)
			
			served_customer += 1
			if slot_2.get_child_count() == 0 and Player_Data.is_tutorial and served_customer == 1:
				slot_2.add_child(create_random_customer())
				slot_2.get_child(0).get_meta("timer").start(slot_2.get_child(0).get_meta("timer").wait_time * 0.75)
				set_state(State.SELECTION)
				tutorial._show_next_step()
			elif tutorial._current_steps >= 2:
				fill_all_slot()
			if served_customer >= 5:
				_on_timer_timeout()
		else:
			if order_text.text[selected_customer.current_letter_index].to_upper() == " ":
				selected_customer.current_letter_index += 1
				selected_customer.typo_checkpoint = selected_customer.current_letter_index
				set_next_character(selected_customer.current_letter_index, false)
	else:
		if Player_Data.typo_shield:
			Player_Data.typo_shield = false
			typo_shield_marker.visible = false
			return
		set_next_character(selected_customer.current_letter_index, true)
		typo_sfx.play()
		selected_customer.current_letter_index = selected_customer.typo_checkpoint
		delay_timer.wait_time = 2
		delay_timer.start()
		selected_customer.char_texture.texture = selected_customer.dissapointed
		await delay_timer.timeout
		selected_customer.char_texture.texture = selected_customer.normal
		combo = 0
		set_next_character(selected_customer.typo_checkpoint, false)
		

		
	
	
func _on_timer_timeout() -> void:
	set_state(State.GAMEOVER)

	
func _on_customer_switch(event: InputEvent):
	var switch_to
	if event.is_action_pressed("switch_left") or event.is_action_pressed("switch_right"):
		if event.is_action_pressed("switch_right"):
			switch_to = selected_customer.get_parent().get_index() + 1
			if switch_to >= slot_count:
				switch_to = 0
		elif event.is_action_pressed("switch_left"):
			switch_to = selected_customer.get_parent().get_index() - 1
			if switch_to < 0:
				switch_to = slot_count-1
		var target_customer = slot_container.get_child(switch_to).get_child(0)
		selected_customer.become_unselected()
		selected_customer = target_customer
		selected_customer.become_selected()
		order_text.text = selected_customer.get_prompt()
		set_next_character(selected_customer.current_letter_index, false)
	
	
func _on_customer_exited(panel: Panel):
	_replace_customer(panel, RemovalReason.TIMED_OUT)

func _replace_customer(customer: Panel, reason: RemovalReason):
	if current_state == State.GAMEOVER:
		return
	
	var slot = customer.get_parent()
	var was_selected = (customer == selected_customer)
	
	match  reason:
		RemovalReason.SERVED:
			pass
		RemovalReason.TIMED_OUT:
			if was_selected:
				set_state(State.SELECTION)
			
	customer.selected.disconnect(_on_customer_switch)
	customer.exited.disconnect(_on_customer_exited)
	slot.remove_child(customer)
	customer.queue_free()
	
	var new_customer = create_random_customer()
	slot.add_child(new_customer)
	
	if was_selected:
		selected_customer = new_customer
		selected_customer.become_selected()
		order_text.text = new_customer.prompt
		set_next_character(new_customer.current_letter_index, false)

func booster_active(text, current_letter_index: int) -> String:
	booster_marker.visible = false
	var result = []
	for word in text.split(" "):
		var stripped = word.strip_edges().rstrip(".,!?;:")
		var suffix = word.substr(stripped.length())
		var word_index = text.find(stripped)

		if angka.has(stripped.to_lower()):
			if word_index >= current_letter_index and word_index != -1:
				result.append(angka[stripped.to_lower()] + suffix)
			else:
				result.append(word)
		else:
			result.append(word)
	selected_customer.prompt = " ".join(result)
	return selected_customer.prompt

func set_next_character(next_character_index: int, on_typo: bool):
	var raw_prompt = selected_customer.prompt
	var typed_text = ""
	var before
	var wrong_word
	var after
	if on_typo:
		var i = selected_customer.current_letter_index
		while i < raw_prompt.length() and raw_prompt[i].to_upper() != " ":
			i +=1
		before = get_bbcode_color_tag(typed) + raw_prompt.substr(0, selected_customer.typo_checkpoint) + "[/color]"
		wrong_word = get_bbcode_color_tag(typo_color) + raw_prompt.substr(selected_customer.typo_checkpoint, i-selected_customer.typo_checkpoint+1) + "[/color]"
		after = get_bbcode_color_tag(remaining) + raw_prompt.substr(i+1) + "[/color]"
	if next_character_index > 0:
		typed_text = get_bbcode_color_tag(typed) + raw_prompt.substr(0, next_character_index) + "[/color]"
	var current_character_text = get_bbcode_color_tag(current_character) + raw_prompt.substr(next_character_index, 1) + "[/color]"
	var remaining_text = ""
	if next_character_index != raw_prompt.length():
		remaining_text = get_bbcode_color_tag(remaining) + raw_prompt.substr(next_character_index + 1) + "[/color]"
	if !on_typo:
		order_text.parse_bbcode("[center][b]" + typed_text + current_character_text + remaining_text + "[/b][/center]"	) 
	else:
		order_text.parse_bbcode("[center][b]" + before + "[shake rate = 5 level = 10]" + wrong_word + "[/shake]" + after + "[/b][/center]")
		
func get_bbcode_color_tag(color: Color) -> String:	
	return "[color=#" + color.to_html(false) + "]"


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.

func turn_stove_on():
	stove.texture = ResourceScript.stove["on"]
	wok.texture = ResourceScript.wok["on"]
	stove_timer.start()


func _turn_stove_off():
	stove.texture = ResourceScript.stove["off"]
	wok.texture = ResourceScript.wok["off"]
